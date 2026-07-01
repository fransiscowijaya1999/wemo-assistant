CREATE INDEX `aliases_updated_idx` ON `aliases` (`updated_at`,`id`);--> statement-breakpoint
CREATE INDEX `assemblies_updated_idx` ON `assemblies` (`updated_at`,`id`);--> statement-breakpoint
CREATE INDEX `assembly_items_updated_idx` ON `assembly_items` (`updated_at`,`id`);--> statement-breakpoint
CREATE INDEX `assembly_links_updated_idx` ON `assembly_links` (`updated_at`,`id`);--> statement-breakpoint
CREATE INDEX `colors_updated_idx` ON `colors` (`updated_at`,`id`);--> statement-breakpoint
CREATE INDEX `dots_updated_idx` ON `dots` (`updated_at`,`id`);--> statement-breakpoint
CREATE INDEX `item_resolutions_updated_idx` ON `item_resolutions` (`updated_at`,`id`);--> statement-breakpoint
CREATE INDEX `machine_variants_updated_idx` ON `machine_variants` (`updated_at`,`id`);--> statement-breakpoint
CREATE INDEX `machines_updated_idx` ON `machines` (`updated_at`,`id`);--> statement-breakpoint
CREATE INDEX `part_color_variants_updated_idx` ON `part_color_variants` (`updated_at`,`id`);--> statement-breakpoint
CREATE INDEX `part_numbers_updated_idx` ON `part_numbers` (`updated_at`,`id`);--> statement-breakpoint
CREATE INDEX `parts_updated_idx` ON `parts` (`updated_at`,`id`);--> statement-breakpoint
CREATE INDEX `service_items_updated_idx` ON `service_items` (`updated_at`,`id`);