import type { ExtractedColorPage, ExtractedPage } from './types';

export type ImageMediaType = 'image/png' | 'image/jpeg' | 'image/webp' | 'image/gif';

export type ExtractCatalogPageInput = {
  imageBase64: string;
  mediaType: ImageMediaType;
  /**
   * Ask the model to locate balloon coordinates (`dots`) for each ref. Default true.
   * When false the model returns empty `dots` arrays — saves output tokens/thinking on
   * pages where the AI-placed dots are too imprecise to be worth keeping (a human places
   * them later in Dot mapping). The diagram bbox is still returned so the image is cropped.
   */
  mapDots?: boolean;
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
