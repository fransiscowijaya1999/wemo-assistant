CREATE TABLE `aliases` (
	`id` text PRIMARY KEY NOT NULL,
	`part_id` text NOT NULL,
	`term` text NOT NULL,
	`lang` text,
	`created_at` integer NOT NULL,
	`updated_at` integer NOT NULL,
	`deleted_at` integer,
	FOREIGN KEY (`part_id`) REFERENCES `parts`(`id`) ON UPDATE no action ON DELETE no action
);
--> statement-breakpoint
CREATE INDEX `aliases_term_idx` ON `aliases` (`term`);--> statement-breakpoint
CREATE TABLE `assemblies` (
	`id` text PRIMARY KEY NOT NULL,
	`machine_id` text NOT NULL,
	`group_type` text NOT NULL,
	`code` text NOT NULL,
	`name` text NOT NULL,
	`image_ref` text,
	`image_code` text,
	`width` integer,
	`height` integer,
	`page_no` integer,
	`sort_order` integer,
	`created_at` integer NOT NULL,
	`updated_at` integer NOT NULL,
	`deleted_at` integer,
	FOREIGN KEY (`machine_id`) REFERENCES `machines`(`id`) ON UPDATE no action ON DELETE no action
);
--> statement-breakpoint
CREATE INDEX `assemblies_machine_code_idx` ON `assemblies` (`machine_id`,`code`);--> statement-breakpoint
CREATE TABLE `assembly_items` (
	`id` text PRIMARY KEY NOT NULL,
	`assembly_id` text NOT NULL,
	`ref_no` text NOT NULL,
	`base_part_id` text,
	`note` text,
	`created_at` integer NOT NULL,
	`updated_at` integer NOT NULL,
	`deleted_at` integer,
	FOREIGN KEY (`assembly_id`) REFERENCES `assemblies`(`id`) ON UPDATE no action ON DELETE no action,
	FOREIGN KEY (`base_part_id`) REFERENCES `parts`(`id`) ON UPDATE no action ON DELETE no action
);
--> statement-breakpoint
CREATE INDEX `assembly_items_assembly_idx` ON `assembly_items` (`assembly_id`);--> statement-breakpoint
CREATE TABLE `assembly_links` (
	`id` text PRIMARY KEY NOT NULL,
	`from_assembly_id` text NOT NULL,
	`to_code` text NOT NULL,
	`to_assembly_id` text,
	`x` real,
	`y` real,
	`label` text,
	`created_at` integer NOT NULL,
	`updated_at` integer NOT NULL,
	`deleted_at` integer,
	FOREIGN KEY (`from_assembly_id`) REFERENCES `assemblies`(`id`) ON UPDATE no action ON DELETE no action,
	FOREIGN KEY (`to_assembly_id`) REFERENCES `assemblies`(`id`) ON UPDATE no action ON DELETE no action
);
--> statement-breakpoint
CREATE INDEX `assembly_links_from_idx` ON `assembly_links` (`from_assembly_id`);--> statement-breakpoint
CREATE TABLE `colors` (
	`id` text PRIMARY KEY NOT NULL,
	`machine_id` text NOT NULL,
	`code` text NOT NULL,
	`name` text NOT NULL,
	`created_at` integer NOT NULL,
	`updated_at` integer NOT NULL,
	`deleted_at` integer,
	FOREIGN KEY (`machine_id`) REFERENCES `machines`(`id`) ON UPDATE no action ON DELETE no action
);
--> statement-breakpoint
CREATE INDEX `colors_machine_idx` ON `colors` (`machine_id`);--> statement-breakpoint
CREATE TABLE `dots` (
	`id` text PRIMARY KEY NOT NULL,
	`assembly_item_id` text NOT NULL,
	`x` real NOT NULL,
	`y` real NOT NULL,
	`created_at` integer NOT NULL,
	`updated_at` integer NOT NULL,
	`deleted_at` integer,
	FOREIGN KEY (`assembly_item_id`) REFERENCES `assembly_items`(`id`) ON UPDATE no action ON DELETE no action
);
--> statement-breakpoint
CREATE INDEX `dots_item_idx` ON `dots` (`assembly_item_id`);--> statement-breakpoint
CREATE TABLE `item_resolutions` (
	`id` text PRIMARY KEY NOT NULL,
	`assembly_item_id` text NOT NULL,
	`part_number_id` text NOT NULL,
	`qty` integer DEFAULT 1 NOT NULL,
	`variant_id` text,
	`serial_from` text,
	`serial_to` text,
	`created_at` integer NOT NULL,
	`updated_at` integer NOT NULL,
	`deleted_at` integer,
	FOREIGN KEY (`assembly_item_id`) REFERENCES `assembly_items`(`id`) ON UPDATE no action ON DELETE no action,
	FOREIGN KEY (`part_number_id`) REFERENCES `part_numbers`(`id`) ON UPDATE no action ON DELETE no action,
	FOREIGN KEY (`variant_id`) REFERENCES `machine_variants`(`id`) ON UPDATE no action ON DELETE no action
);
--> statement-breakpoint
CREATE INDEX `item_resolutions_item_idx` ON `item_resolutions` (`assembly_item_id`);--> statement-breakpoint
CREATE TABLE `machine_variants` (
	`id` text PRIMARY KEY NOT NULL,
	`machine_id` text NOT NULL,
	`name` text NOT NULL,
	`note` text,
	`created_at` integer NOT NULL,
	`updated_at` integer NOT NULL,
	`deleted_at` integer,
	FOREIGN KEY (`machine_id`) REFERENCES `machines`(`id`) ON UPDATE no action ON DELETE no action
);
--> statement-breakpoint
CREATE INDEX `machine_variants_machine_idx` ON `machine_variants` (`machine_id`);--> statement-breakpoint
CREATE TABLE `machines` (
	`id` text PRIMARY KEY NOT NULL,
	`brand` text NOT NULL,
	`model` text NOT NULL,
	`type_code` text,
	`k_code` text,
	`market` text,
	`engine_series` text,
	`frame_series` text,
	`year_from` integer,
	`year_to` integer,
	`catalog_edition` text,
	`catalog_date` text,
	`notes` text,
	`created_at` integer NOT NULL,
	`updated_at` integer NOT NULL,
	`deleted_at` integer
);
--> statement-breakpoint
CREATE TABLE `part_color_variants` (
	`id` text PRIMARY KEY NOT NULL,
	`part_id` text NOT NULL,
	`color_id` text NOT NULL,
	`suffix_code` text,
	`full_number` text,
	`created_at` integer NOT NULL,
	`updated_at` integer NOT NULL,
	`deleted_at` integer,
	FOREIGN KEY (`part_id`) REFERENCES `parts`(`id`) ON UPDATE no action ON DELETE no action,
	FOREIGN KEY (`color_id`) REFERENCES `colors`(`id`) ON UPDATE no action ON DELETE no action
);
--> statement-breakpoint
CREATE INDEX `part_color_variants_part_idx` ON `part_color_variants` (`part_id`);--> statement-breakpoint
CREATE TABLE `part_numbers` (
	`id` text PRIMARY KEY NOT NULL,
	`part_id` text NOT NULL,
	`value` text NOT NULL,
	`kind` text DEFAULT 'oem' NOT NULL,
	`brand` text,
	`note` text,
	`is_primary` integer DEFAULT false NOT NULL,
	`created_at` integer NOT NULL,
	`updated_at` integer NOT NULL,
	`deleted_at` integer,
	FOREIGN KEY (`part_id`) REFERENCES `parts`(`id`) ON UPDATE no action ON DELETE no action
);
--> statement-breakpoint
CREATE INDEX `part_numbers_value_idx` ON `part_numbers` (`value`);--> statement-breakpoint
CREATE INDEX `part_numbers_part_idx` ON `part_numbers` (`part_id`);--> statement-breakpoint
CREATE TABLE `parts` (
	`id` text PRIMARY KEY NOT NULL,
	`name_raw` text NOT NULL,
	`name_normalized` text,
	`category` text,
	`specs` text,
	`notes` text,
	`created_at` integer NOT NULL,
	`updated_at` integer NOT NULL,
	`deleted_at` integer
);
--> statement-breakpoint
CREATE INDEX `parts_name_normalized_idx` ON `parts` (`name_normalized`);--> statement-breakpoint
CREATE TABLE `service_items` (
	`id` text PRIMARY KEY NOT NULL,
	`assembly_id` text NOT NULL,
	`ref_no` text,
	`name` text NOT NULL,
	`frt_hours` real,
	`note` text,
	`created_at` integer NOT NULL,
	`updated_at` integer NOT NULL,
	`deleted_at` integer,
	FOREIGN KEY (`assembly_id`) REFERENCES `assemblies`(`id`) ON UPDATE no action ON DELETE no action
);
--> statement-breakpoint
CREATE INDEX `service_items_assembly_idx` ON `service_items` (`assembly_id`);--> statement-breakpoint
CREATE TABLE `users` (
	`id` text PRIMARY KEY NOT NULL,
	`email` text NOT NULL,
	`role` text DEFAULT 'clerk' NOT NULL,
	`display_name` text,
	`created_at` integer NOT NULL,
	`updated_at` integer NOT NULL,
	`deleted_at` integer
);
--> statement-breakpoint
CREATE UNIQUE INDEX `users_email_unique` ON `users` (`email`);