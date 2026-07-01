export type ExtractedPartNumber = { value: string; brand?: string | null; note?: string | null };

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

export type CommitSummary = {
  assemblyId: string;
  itemsCreated: number;
  partsCreated: number;
  partsReused: number;
  numbersCreated: number;
  serviceItemsCreated: number;
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

export type FullItem = {
  id: string;
  refNo: string;
  description?: string | null;
  part: { nameRaw: string } | null;
  dots: EditorDot[];
};

export type FullAssembly = { assembly: Assembly; items: FullItem[] };

export type PartFull = {
  id: string;
  nameRaw: string;
  nameNormalized?: string | null;
  category?: string | null;
  notes?: string | null;
  numbers: { value: string; kind: string; brand?: string | null; note?: string | null; isPrimary: boolean }[];
  colorVariants: { id: string; colorId: string; suffixCode?: string | null; fullNumber?: string | null }[];
};
