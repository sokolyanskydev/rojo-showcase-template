--!strict

export type Vector = Vector3

export type PuddleInstance = {
	Id: string,
	Position: Vector3,
	Radius: number,
	CreatedAt: number,
	ExpiresAt: number,
	DamagePerSecond: number,
	SlowMultiplier: number,
}


