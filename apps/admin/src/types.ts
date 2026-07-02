export type ExtractedVariantQty = { variant: string; qty: number | null };

export type ExtractedPartNumber = {
  value: string;
  brand?: string | null;
  note?: string | null;
  serialFrom?: string | null;
  serialTo?: string | null;
  variantQtys?: ExtractedVariantQty[];
};

export type ExtractedItem = {
  refNo: string;
  description: string;
  qty?: number | null;
  partNumbers: ExtractedPartNumber[];
  dots?: { x: number; y: number }[];
};

export type ExtractedServiceItem = { refNo?: string | null; name: string; frtHours?: number | null };

export type DiagramBox = { x: number; y: number; width: number; height: number };

export type ExtractedPage = {
  assembly: { code: string; name: string; imageCode?: string | null };
  diagram?: DiagramBox | null;
  items: ExtractedItem[];
  serviceItems: ExtractedServiceItem[];
  variantColumns?: string[];
};

export type ExtractedColorPage = {
  colors: { code: string; name: string }[];
  items: {
    partName: string;
    baseNumber: string;
    blockCode?: string | null;
    refNo?: string | null;
    variants: { colorCode: string; suffix: string }[];
  }[];
};

export type Machine = { id: string; brand: string; model: string; typeCode?: string | null };

export type SearchResult = { partId: string; name: string; primaryNumber: string | null };

export type AiSettings = {
  chatProvider: string;
  chatModel: string;
  visionModel: string;
  visionModelEffective: string;
  anthropicKey: string;
  deepseekKey: string;
  activeChatProvider: 'anthropic' | 'deepseek' | 'stub' | null;
  visionConfigured: boolean;
};

export type MachineVariant = { id: string; name: string; note?: string | null };

export type CommitSummary = {
  assemblyId: string;
  itemsCreated: number;
  partsCreated: number;
  partsReused: number;
  numbersCreated: number;
  serviceItemsCreated: number;
  resolutionsCreated: number;
  machineVariantsCreated: number;
  assembliesReplaced: number;
};

export type ColorCommitSummary = {
  colorsCreated: number;
  colorsReused: number;
  partsCreated: number;
  partsReused: number;
  variantsCreated: number;
  variantsSkipped: number;
};

// --- Dot mapping / browse ---

export type Assembly = {
  id: string;
  code: string;
  name: string;
  groupType: string;
  imageRef?: string | null;
  width?: number | null;
  height?: number | null;
};

export type EditorDot = { assemblyItemId: string; x: number; y: number };

export type Resolution = {
  id: string;
  partNumberId: string;
  partNumberValue: string | null;
  qty: number;
  variantId: string | null;
  variantName: string | null;
  serialFrom: string | null;
  serialTo: string | null;
};

export type FullItem = {
  id: string;
  refNo: string;
  description?: string | null;
  part: { nameRaw: string } | null;
  resolutions: Resolution[];
  dots: EditorDot[];
};

export type FullAssembly = { assembly: Assembly; items: FullItem[] };

export type Applicability = {
  number: string | null;
  qty: number;
  variantName: string | null;
  serialFrom: string | null;
  serialTo: string | null;
};

export type Placement = {
  assemblyItemId: string;
  refNo: string;
  assemblyId: string;
  assemblyCode: string;
  assemblyName: string;
  machineId: string;
  machine: string;
  applicability: Applicability[];
};

export type PartFull = {
  id: string;
  nameRaw: string;
  nameNormalized?: string | null;
  category?: string | null;
  notes?: string | null;
  numbers: { value: string; kind: string; brand?: string | null; note?: string | null; isPrimary: boolean }[];
  colorVariants: { id: string; colorId: string; suffixCode?: string | null; fullNumber?: string | null }[];
  placements: Placement[];
};
