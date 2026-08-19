import { Router, type IRouter } from "express";
import { eq } from "drizzle-orm";
import { db, sitePagesTable } from "@workspace/db";
import {
  CreatePageBody,
  UpdatePageBody,
  UpdatePageParams,
  DeletePageParams,
  GetPageBySlugParams,
} from "@workspace/api-zod";

const router: IRouter = Router();

function isAdmin(req: any): boolean {
  return !!(req.session as any)?.adminAuthenticated;
}

function slugify(title: string): string {
  return title
    .toLowerCase()
    .trim()
    .replace(/[^a-z0-9\u0600-\u06FF]+/g, "-")
    .replace(/^-+|-+$/g, "") || `page-${Date.now()}`;
}

// List pages — public sees only published; admin sees all
router.get("/pages", async (req, res): Promise<void> => {
  const rows = await db.select().from(sitePagesTable).orderBy(sitePagesTable.createdAt);
  const result = isAdmin(req) ? rows : rows.filter((p) => p.published);
  res.json(result);
});

// Get a published page by slug (public)
router.get("/pages/slug/:slug", async (req, res): Promise<void> => {
  const params = GetPageBySlugParams.safeParse(req.params);
  if (!params.success) {
    res.status(400).json({ error: params.error.message });
    return;
  }

  const [page] = await db
    .select()
    .from(sitePagesTable)
    .where(eq(sitePagesTable.slug, params.data.slug));

  if (!page || (!page.published && !isAdmin(req))) {
    res.status(404).json({ error: "Page not found" });
    return;
  }

  res.json(page);
});

// Create page (admin)
router.post("/pages", async (req, res): Promise<void> => {
  if (!isAdmin(req)) {
    res.status(401).json({ error: "Unauthorized" });
    return;
  }

  const parsed = CreatePageBody.safeParse(req.body);
  if (!parsed.success) {
    res.status(400).json({ error: parsed.error.message });
    return;
  }

  const { title, published, blocks } = parsed.data;
  let slug = slugify(title);

  // Ensure slug uniqueness
  const [existing] = await db.select().from(sitePagesTable).where(eq(sitePagesTable.slug, slug));
  if (existing) slug = `${slug}-${Date.now().toString(36)}`;

  const [page] = await db
    .insert(sitePagesTable)
    .values({
      title,
      slug,
      published: published ?? true,
      blocks: (blocks ?? []) as any,
    })
    .returning();

  res.status(201).json(page);
});

// Update page (admin)
router.put("/pages/:id", async (req, res): Promise<void> => {
  if (!isAdmin(req)) {
    res.status(401).json({ error: "Unauthorized" });
    return;
  }

  const params = UpdatePageParams.safeParse(req.params);
  if (!params.success) {
    res.status(400).json({ error: params.error.message });
    return;
  }

  const parsed = UpdatePageBody.safeParse(req.body);
  if (!parsed.success) {
    res.status(400).json({ error: parsed.error.message });
    return;
  }

  const update: Record<string, unknown> = {};
  if (parsed.data.title !== undefined) update.title = parsed.data.title;
  if (parsed.data.published !== undefined) update.published = parsed.data.published;
  if (parsed.data.blocks !== undefined) update.blocks = parsed.data.blocks as any;

  if (Object.keys(update).length === 0) {
    res.status(400).json({ error: "No fields to update" });
    return;
  }

  const [page] = await db
    .update(sitePagesTable)
    .set(update)
    .where(eq(sitePagesTable.id, params.data.id))
    .returning();

  if (!page) {
    res.status(404).json({ error: "Page not found" });
    return;
  }

  res.json(page);
});

// Delete page (admin)
router.delete("/pages/:id", async (req, res): Promise<void> => {
  if (!isAdmin(req)) {
    res.status(401).json({ error: "Unauthorized" });
    return;
  }

  const params = DeletePageParams.safeParse(req.params);
  if (!params.success) {
    res.status(400).json({ error: params.error.message });
    return;
  }

  const [page] = await db
    .delete(sitePagesTable)
    .where(eq(sitePagesTable.id, params.data.id))
    .returning();

  if (!page) {
    res.status(404).json({ error: "Page not found" });
    return;
  }

  res.sendStatus(204);
});

export default router;
