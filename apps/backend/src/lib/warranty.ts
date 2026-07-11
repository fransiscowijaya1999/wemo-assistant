import type { WarrantyPeriodUnit } from '../db/schema';

/**
 * Calculate the expiry date for a warranty based on start date and period.
 */
export function calculateWarrantyExpiry(
  startDate: Date | number,
  periodValue: number,
  periodUnit: WarrantyPeriodUnit
): Date {
  const date = new Date(startDate);
  if (periodUnit === 'days') {
    date.setDate(date.getDate() + periodValue);
  } else {
    date.setMonth(date.getMonth() + periodValue);
  }
  return date;
}

/**
 * Calculate warranty expiry timestamp (milliseconds since epoch).
 */
export function calculateWarrantyExpiryMs(
  startDate: Date | number,
  periodValue: number,
  periodUnit: WarrantyPeriodUnit
): number {
  return calculateWarrantyExpiry(startDate, periodValue, periodUnit).getTime();
}

/**
 * Check if a warranty is still active (not expired).
 */
export function isWarrantyActive(expiryDate: Date | number | null | undefined): boolean {
  if (!expiryDate) return false;
  const expiryMs = expiryDate instanceof Date ? expiryDate.getTime() : expiryDate;
  return expiryMs > Date.now();
}

/**
 * Get days until warranty expiry (negative if expired).
 */
export function getDaysUntilExpiry(expiryDate: Date | number | null | undefined): number {
  if (!expiryDate) return -Infinity;
  const expiryMs = expiryDate instanceof Date ? expiryDate.getTime() : expiryDate;
  return Math.floor((expiryMs - Date.now()) / (1000 * 60 * 60 * 24));
}

/**
 * Create warranty fields for a maintenance item.
 * If hasWarranty is true and periodValue/periodUnit are set, calculates expiry.
 */
export function createWarrantyFields(
  hasWarranty: boolean,
  periodValue: number | undefined | null,
  periodUnit: WarrantyPeriodUnit | undefined | null,
  startDate: Date | number = new Date()
): {
  hasWarranty: boolean;
  warrantyPeriodValue: number | null;
  warrantyPeriodUnit: WarrantyPeriodUnit | null;
  warrantyStartDate: number;
  warrantyExpiryDate: number | null;
} {
  if (!hasWarranty || periodValue == null || periodUnit == null) {
    return {
      hasWarranty: false,
      warrantyPeriodValue: null,
      warrantyPeriodUnit: null,
      warrantyStartDate: startDate instanceof Date ? startDate.getTime() : startDate,
      warrantyExpiryDate: null,
    };
  }

  const startMs = startDate instanceof Date ? startDate.getTime() : startDate;
  const expiryMs = calculateWarrantyExpiryMs(startDate, periodValue, periodUnit);

  return {
    hasWarranty: true,
    warrantyPeriodValue: periodValue,
    warrantyPeriodUnit: periodUnit,
    warrantyStartDate: startMs,
    warrantyExpiryDate: expiryMs,
  };
}
