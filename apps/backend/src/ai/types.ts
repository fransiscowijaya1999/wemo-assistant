import { z } from 'zod';

// Structured shape extracted from a single catalog assembly page. Maps onto the
// draft rows an admin reviews before they become assemblies/parts/part_numbers.
// See docs/catalog-format.md.

export const extractedPartNumber = z.object({
  value: z.string().describe('The part number exactly as printed, e.g. 12200-KVY-900.'),
  brand: z.string().nullable().optional().describe('Brand if indicated, e.g. NGK, Denso, Honda.'),
  note: z.string().nullable().optional().describe('Any note, e.g. supersession or spec in parentheses.'),
});

export const extractedItem = z.object({
  refNo: z.string().describe('The balloon/reference number from the "No." column (verbatim).'),
  description: z.string().describe('The part description exactly as printed (English, comma-inverted).'),
  qty: z.number().int().nullable().optional().describe('Quantity from the QTY column.'),
  partNumbers: z
    .array(extractedPartNumber)
    .describe('All part numbers listed for this ref, including alternates/interchangeable ones.'),
});

export const extractedServiceItem = z.object({
  refNo: z.string().nullable().optional(),
  name: z.string().describe('Service item name from the Service item / F.R.T. table.'),
  frtHours: z.number().nullable().optional().describe('Flat-rate labor hours (F.R.T.).'),
});

export const extractedPage = z.object({
  assembly: z.object({
    code: z.string().describe('Assembly code, e.g. E-3 or F-13.'),
    name: z.string().describe('Assembly name, e.g. Cylinder Head.'),
    imageCode: z.string().nullable().optional().describe('Internal diagram image code, e.g. KVYIE0300.'),
  }),
  items: z.array(extractedItem),
  serviceItems: z.array(extractedServiceItem),
});

export type ExtractedPage = z.infer<typeof extractedPage>;

// --- Color-index page ---
// Maps colored parts to color-specific part-number suffixes. See docs/catalog-format.md.

export const extractedColorLegend = z.object({
  code: z.string().describe('Color code from the column header, e.g. NH-436M.'),
  name: z.string().describe('Color name, e.g. Mat Gunpowder Black Metallic.'),
});

export const extractedColorVariant = z.object({
  colorCode: z.string().describe("The column's color code this suffix belongs to (matches a legend code)."),
  suffix: z.string().describe('Color suffix code appended to the base part number, e.g. ZE.'),
});

export const extractedColoredPart = z.object({
  partName: z.string(),
  baseNumber: z.string().describe('Base part number ("No. part dasar"), e.g. 83650-K1Z-NA0.'),
  blockCode: z.string().nullable().optional().describe('Assembly/block code ("No. blok"), e.g. F-13.'),
  refNo: z.string().nullable().optional().describe('Balloon/ref number ("No. Ref") within that block.'),
  variants: z.array(extractedColorVariant),
});

export const extractedColorPage = z.object({
  colors: z.array(extractedColorLegend),
  items: z.array(extractedColoredPart),
});

export type ExtractedColorPage = z.infer<typeof extractedColorPage>;
