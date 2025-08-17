--!strict

export type PuddleConfig = {
	Radius: number,
	DurationSeconds: number,
	DamagePerSecond: number,
	SlowMultiplier: number,
	TickSeconds: number,
	MaxCastRange: number,
}

export type EnemyConfig = {
	SpawnIntervalSeconds: number,
	SpawnRadius: number,
	BaseHealth: number,
	WalkSpeed: number,
}

export type GameConfig = {
	Puddle: PuddleConfig,
	Enemy: EnemyConfig,
	CastCooldownSeconds: number,
}

local config: GameConfig = {
	Puddle = {
		Radius = 24,
		DurationSeconds = 8,
		DamagePerSecond = 10,
		SlowMultiplier = 0.4, -- 60% slow
		TickSeconds = 0.25,
		MaxCastRange = 90,
	},
	Enemy = {
		SpawnIntervalSeconds = 2,
		SpawnRadius = 160,
		BaseHealth = 50,
		WalkSpeed = 12,
	},
	CastCooldownSeconds = 3,
}

return config


