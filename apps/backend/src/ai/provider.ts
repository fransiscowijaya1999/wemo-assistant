import type { ExtractedPage } from './types';

export type ImageMediaType = 'image/png' | 'image/jpeg' | 'image/webp' | 'image/gif';

export type ExtractCatalogPageInput = {
  imageBase64: string;
  mediaType: ImageMediaType;
};

/**
 * Model-agnostic seam for catalog-page extraction. Implementations wrap a specific
 * AI provider (Claude today; OpenAI/Gemini/local swappable later). App code depends
 * only on this interface.
 */
export interface VisionExtractionProvider {
  extractCatalogPage(input: ExtractCatalogPageInput): Promise<ExtractedPage>;
}
