import { PrismaClient, Role } from '@prisma/client';
import * as bcrypt from 'bcrypt';

const prisma = new PrismaClient();

const products = [
  ['conveyors', 'Conveyors', 'Smart conveying solutions for efficient material movement.', 'precision_manufacturing_outlined'],
  ['mixer', 'Mixer', 'Uniform and reliable industrial mixing solutions.', 'blender_outlined'],
  ['washer', 'Washer', 'Hygienic automated washing for crates and pallets.', 'water_drop_outlined'],
  ['snacks-machines', 'Snacks Machines', 'Complete processing solutions for consistent snack production.', 'fastfood_outlined'],
] as const;

async function main() {
  const adminEmail = (process.env.ADMIN_EMAIL ?? 'admin@hyway.local').toLowerCase();
  const adminPassword = process.env.ADMIN_PASSWORD ?? 'ChangeMe123!';
  await prisma.user.upsert({
    where: { email: adminEmail },
    update: { role: Role.ADMIN },
    create: {
      name: 'HYWAY Admin',
      email: adminEmail,
      passwordHash: await bcrypt.hash(adminPassword, 12),
      role: Role.ADMIN,
    },
  });

  await prisma.product.deleteMany({
    where: { slug: { notIn: products.map(([slug]) => slug) } },
  });

  for (const [index, product] of products.entries()) {
    const [slug, name, shortDescription, icon] = product;
    await prisma.product.upsert({
      where: { slug },
      update: { name, shortDescription, icon, sortOrder: index },
      create: {
        slug,
        name,
        shortDescription,
        description: `${name} engineered for reliable, efficient and hygienic industrial food production.`,
        icon,
        sortOrder: index,
        images: {
          create: { url: `/assets/images/category-${slug}.png`, altText: name },
        },
      },
    });
  }
}

main()
  .then(() => prisma.$disconnect())
  .catch(async (error) => {
    console.error(error);
    await prisma.$disconnect();
    process.exit(1);
  });
