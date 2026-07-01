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
