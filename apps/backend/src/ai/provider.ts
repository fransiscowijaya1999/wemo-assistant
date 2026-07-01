import type { ExtractedColorPage, ExtractedPage } from './types';

export type ImageMediaType = 'image/png' | 'image/jpeg' | 'image/webp' | 'image/gif';

export type ExtractCatalogPageInput = {
  imageBase64: string;
  mediaType: ImageMediaType;
};

/**
 * Model-agnostic seam for catalog extraction. Implementations wrap a specific AI
 * provider (Claude today; OpenAI/Gemini/local swappable later). App code depends
 * only on this interface.
 */
export interface VisionExtractionProvider {
  /** Assembly detail page -> assembly + parts table + FRT table. */
  extractCatalogPage(input: ExtractCatalogPageInput): Promise<ExtractedPage>;
  /** Color-index page -> color legend + per-color part-number suffixes. */
  extractColorPage(input: ExtractCatalogPageInput): Promise<ExtractedColorPage>;
}
