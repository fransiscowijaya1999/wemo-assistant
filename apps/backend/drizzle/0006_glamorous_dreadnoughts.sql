CREATE TABLE `customer_vehicles` (
	`id` text PRIMARY KEY NOT NULL,
	`customer_id` text NOT NULL,
	`machine_id` text NOT NULL,
	`license_plate` text,
	`frame_number` text,
	`color_id` text,
	`year` integer,
	`nickname` text,
	`notes` text,
	`created_at` integer NOT NULL,
	`updated_at` integer NOT NULL,
	`deleted_at` integer,
	FOREIGN KEY (`customer_id`) REFERENCES `customers`(`id`) ON UPDATE no action ON DELETE no action,
	FOREIGN KEY (`machine_id`) REFERENCES `machines`(`id`) ON UPDATE no action ON DELETE no action,
	FOREIGN KEY (`color_id`) REFERENCES `colors`(`id`) ON UPDATE no action ON DELETE no action
);
--> statement-breakpoint
CREATE INDEX `customer_vehicles_customer_idx` ON `customer_vehicles` (`customer_id`);--> statement-breakpoint
CREATE INDEX `customer_vehicles_machine_idx` ON `customer_vehicles` (`machine_id`);--> statement-breakpoint
CREATE INDEX `customer_vehicles_plate_idx` ON `customer_vehicles` (`license_plate`);--> statement-breakpoint
CREATE INDEX `customer_vehicles_updated_idx` ON `customer_vehicles` (`updated_at`,`id`);--> statement-breakpoint
CREATE TABLE `customers` (
	`id` text PRIMARY KEY NOT NULL,
	`name` text NOT NULL,
	`phone` text,
	`phone_alt` text,
	`email` text,
	`address` text,
	`notes` text,
	`tag` text,
	`created_at` integer NOT NULL,
	`updated_at` integer NOT NULL,
	`deleted_at` integer
);
--> statement-breakpoint
CREATE INDEX `customers_name_idx` ON `customers` (`name`);--> statement-breakpoint
CREATE INDEX `customers_phone_idx` ON `customers` (`phone`);--> statement-breakpoint
CREATE INDEX `customers_updated_idx` ON `customers` (`updated_at`,`id`);--> statement-breakpoint
CREATE TABLE `maintenance_items` (
	`id` text PRIMARY KEY NOT NULL,
	`maintenance_record_id` text NOT NULL,
	`category` text NOT NULL,
	`part_id` text,
	`part_number_id` text,
	`part_number` text,
	`brand` text,
	`quantity` integer DEFAULT 1 NOT NULL,
	`has_warranty` integer DEFAULT false NOT NULL,
	`warranty_period_value` integer,
	`warranty_period_unit` text,
	`warranty_start_date` integer,
	`warranty_expiry_date` integer,
	`warranty_notes` text,
	`unit_price` integer,
	`notes` text,
	`sort_order` integer DEFAULT 0 NOT NULL,
	`created_at` integer NOT NULL,
	`updated_at` integer NOT NULL,
	`deleted_at` integer,
	FOREIGN KEY (`maintenance_record_id`) REFERENCES `maintenance_records`(`id`) ON UPDATE no action ON DELETE no action,
	FOREIGN KEY (`part_id`) REFERENCES `parts`(`id`) ON UPDATE no action ON DELETE no action,
	FOREIGN KEY (`part_number_id`) REFERENCES `part_numbers`(`id`) ON UPDATE no action ON DELETE no action
);
--> statement-breakpoint
CREATE INDEX `maintenance_items_record_idx` ON `maintenance_items` (`maintenance_record_id`);--> statement-breakpoint
CREATE INDEX `maintenance_items_part_idx` ON `maintenance_items` (`part_id`);--> statement-breakpoint
CREATE INDEX `maintenance_items_part_number_idx` ON `maintenance_items` (`part_number_id`);--> statement-breakpoint
CREATE INDEX `maintenance_items_category_idx` ON `maintenance_items` (`category`);--> statement-breakpoint
CREATE INDEX `maintenance_items_brand_idx` ON `maintenance_items` (`brand`);--> statement-breakpoint
CREATE INDEX `maintenance_items_warranty_expiry_idx` ON `maintenance_items` (`warranty_expiry_date`);--> statement-breakpoint
CREATE INDEX `maintenance_items_updated_idx` ON `maintenance_items` (`updated_at`,`id`);--> statement-breakpoint
CREATE TABLE `maintenance_records` (
	`id` text PRIMARY KEY NOT NULL,
	`customer_vehicle_id` text,
	`customer_id` text NOT NULL,
	`type` text NOT NULL,
	`date` integer NOT NULL,
	`description` text NOT NULL,
	`technician_id` text,
	`clerk_id` text,
	`invoice_number` text,
	`total_amount` integer,
	`notes` text,
	`created_at` integer NOT NULL,
	`updated_at` integer NOT NULL,
	`deleted_at` integer,
	FOREIGN KEY (`customer_vehicle_id`) REFERENCES `customer_vehicles`(`id`) ON UPDATE no action ON DELETE no action,
	FOREIGN KEY (`customer_id`) REFERENCES `customers`(`id`) ON UPDATE no action ON DELETE no action,
	FOREIGN KEY (`technician_id`) REFERENCES `users`(`id`) ON UPDATE no action ON DELETE no action,
	FOREIGN KEY (`clerk_id`) REFERENCES `users`(`id`) ON UPDATE no action ON DELETE no action
);
--> statement-breakpoint
CREATE INDEX `maintenance_records_customer_idx` ON `maintenance_records` (`customer_id`);--> statement-breakpoint
CREATE INDEX `maintenance_records_vehicle_idx` ON `maintenance_records` (`customer_vehicle_id`);--> statement-breakpoint
CREATE INDEX `maintenance_records_type_idx` ON `maintenance_records` (`type`);--> statement-breakpoint
CREATE INDEX `maintenance_records_date_idx` ON `maintenance_records` (`date`);--> statement-breakpoint
CREATE INDEX `maintenance_records_updated_idx` ON `maintenance_records` (`updated_at`,`id`);