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
