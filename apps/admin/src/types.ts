export type ExtractedPartNumber = { value: string; brand?: string | null; note?: string | null };

export type ExtractedItem = {
  refNo: string;
  description: string;
  qty?: number | null;
  partNumbers: ExtractedPartNumber[];
};

export type ExtractedServiceItem = { refNo?: string | null; name: string; frtHours?: number | null };

export type ExtractedPage = {
  assembly: { code: string; name: string; imageCode?: string | null };
  items: ExtractedItem[];
  serviceItems: ExtractedServiceItem[];
};

export type Machine = { id: string; brand: string; model: string; typeCode?: string | null };

// --- Dot mapping ---

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
