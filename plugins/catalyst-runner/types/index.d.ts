export type Run = { moves: number; route: string | null; startedAt: number }
export type Delivery = { seconds: number; moves: number; tokens: number | null }

declare module 'claude-code' {
  interface PluginState {
    'catalyst-runner': { run: Run; delivery: Delivery | null }
  }
}
