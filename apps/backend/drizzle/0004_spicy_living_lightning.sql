CREATE TABLE `part_substitutes` (
	`id` text PRIMARY KEY NOT NULL,
	`part_id` text NOT NULL,
	`substitute_part_id` text NOT NULL,
	`note` text,
	`created_at` integer NOT NULL,
	`updated_at` integer NOT NULL,
	`deleted_at` integer,
	FOREIGN KEY (`part_id`) REFERENCES `parts`(`id`) ON UPDATE no action ON DELETE no action,
	FOREIGN KEY (`substitute_part_id`) REFERENCES `parts`(`id`) ON UPDATE no action ON DELETE no action
);
--> statement-breakpoint
CREATE INDEX `part_substitutes_part_idx` ON `part_substitutes` (`part_id`);--> statement-breakpoint
CREATE INDEX `part_substitutes_sub_idx` ON `part_substitutes` (`substitute_part_id`);--> statement-breakpoint
CREATE INDEX `part_substitutes_updated_idx` ON `part_substitutes` (`updated_at`,`id`);