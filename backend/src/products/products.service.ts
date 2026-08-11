import {
  ConflictException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';
import { CreateProductDto } from './dto/create-product.dto';
import { UpdateProductDto } from './dto/update-product.dto';

const productInclude = { images: { orderBy: { sortOrder: 'asc' as const } } };

@Injectable()
export class ProductsService {
  constructor(private readonly prisma: PrismaService) {}

  findAll(includeInactive = false) {
    return this.prisma.product.findMany({
      where: includeInactive ? undefined : { isActive: true },
      include: productInclude,
      orderBy: [{ sortOrder: 'asc' }, { name: 'asc' }],
    });
  }

  async findOne(slug: string) {
    const product = await this.prisma.product.findUnique({
      where: { slug },
      include: productInclude,
    });
    if (!product) throw new NotFoundException('Product not found');
    return product;
  }

  async create(dto: CreateProductDto) {
    try {
      return await this.prisma.product.create({
        data: {
          ...dto,
          slug: dto.slug.trim().toLowerCase(),
          images: { create: dto.images },
        },
        include: productInclude,
      });
    } catch (error) {
      if (
        error instanceof Prisma.PrismaClientKnownRequestError &&
        error.code === 'P2002'
      ) {
        throw new ConflictException('Product slug already exists');
      }
      throw error;
    }
  }

  async update(slug: string, dto: UpdateProductDto) {
    await this.findOne(slug);
    const { images, ...data } = dto;
    return this.prisma.product.update({
      where: { slug },
      data: {
        ...data,
        ...(dto.slug ? { slug: dto.slug.trim().toLowerCase() } : {}),
        ...(images ? { images: { deleteMany: {}, create: images } } : {}),
      },
      include: productInclude,
    });
  }

  async remove(slug: string) {
    await this.findOne(slug);
    await this.prisma.product.delete({ where: { slug } });
    return { message: 'Product deleted successfully' };
  }
}
