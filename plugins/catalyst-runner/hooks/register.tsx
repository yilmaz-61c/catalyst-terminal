import { atom, read, update } from 'claude-code'
import type { Register } from 'claude-code'

import type { Delivery, Run } from '../types'

const YELLOW = '#ffd60a'

// Kept in step with ~/.config/catalyst/districts.json
const DISTRICTS: Record<string, { name: string; accent: string }> = {
  downtown: { name: 'DOWNTOWN', accent: '#e8322c' },
  anchor: { name: 'ANCHOR', accent: '#ff4f9a' },
  'the-view': { name: 'THE VIEW', accent: '#1fc8e8' },
  rezoning: { name: 'REZONING', accent: '#ff7a1a' },
  kruger: { name: 'KRUGER HQ', accent: '#3d8bff' },
  omnistat: { name: 'OMNISTAT TUNNELS', accent: '#ffd60a' },
}

// The district this session runs in: the terminal tab's, else picked here
let district = 'downtown'
let RED = DISTRICTS.downtown.accent
const run = atom({ plugin: 'catalyst-runner', key: 'run' } as const, { moves: 0, route: null, startedAt: 0 } as Run)
const delivery = atom({ plugin: 'catalyst-runner', key: 'delivery' } as const, null as Delivery | null)

// Turn-end line: "Baked for 3s" becomes "Wallran for 3s"
const PAST = ['Ran', 'Sprinted', 'Wallran', 'Vaulted', 'Climbed', 'Leapt', 'Slid', 'Raced', 'Delivered']

// 1234 -> 1.2K, 48210 -> 48.2K, 1500000 -> 1.5M
const fmt = (n: number) =>
  n >= 1e6 ? `${(n / 1e6).toFixed(1)}M` : n >= 1e3 ? `${(n / 1e3).toFixed(1)}K` : `${n}`

type TokenLine = { text: string; shown: boolean }

// Token lines by the turn's duration, which the TurnDuration row also carries
const tokenLines = new Map<number, TokenLine>()

const findLine = (durationMs: number) => {
  let best: TokenLine | undefined
  let gap = 1000
  for (const [ms, line] of tokenLines) {
    if (Math.abs(ms - durationMs) <= gap) {
      gap = Math.abs(ms - durationMs)
      best = line
    }
  }

  return best
}

const meter = (n: number, size = 10) => '▰'.repeat(Math.min(n, size)) + '▱'.repeat(Math.max(size - n, 0))

export const register: Register = on => {
  on('session.start', async ($, e, next) => {
    const fromTab = await $.env.get('CATALYST_DISTRICT')
    const slugs = Object.keys(DISTRICTS)
    district = fromTab && DISTRICTS[fromTab] ? fromTab : slugs[Math.floor(Math.random() * slugs.length)]
    RED = DISTRICTS[district].accent
    // The status line is started by this process, so it sees the same district
    await $.env.set('CATALYST_DISTRICT', district)

    if (e.isInteractive) {
      const { deny } = await $.config.set({ key: 'theme', value: `custom:catalyst-${district}` })
      if (deny) {
        $.ui.log(`catalyst-runner: theme not switched: ${deny}`, { to: 'debug' })
      }
    }

    if (e.surface === 'terminal') {
      $.ui.toast(`◆ RUNNER NETWORK ONLINE — ${DISTRICTS[district].name}`)
    }

    return next(e)
  })

  on('prompt.submit', async ($, e, next) => {
    const startedAt = await $.clock.now()
    await update($, run, () => ({ moves: 0, route: null, startedAt }))
    await update($, delivery, () => null)

    return next(e)
  })

  on('tool.call', async ($, e, next) => {
    await update($, run, r => ({ ...r, moves: r.moves + 1, route: e.tool }))

    return next(e)
  })

  on('turn.complete', async ($, e, next) => {
    // Subagents finish turns too; only the main conversation is reported
    if (e.agentId) {
      return next(e)
    }

    const result = await next(e)
    const r = await read($, run)
    const seconds = Math.round(((await $.clock.now()) - r.startedAt) / 1000)
    // The event carries the turn's summed usage; core also hands it back in the result
    const u = e.usage ?? result.usage
    const tokens = u
      ? u.input_tokens + u.output_tokens + u.cache_read_input_tokens + u.cache_creation_input_tokens
      : null
    await update($, delivery, () => ({ seconds, moves: r.moves, tokens }))

    if (u && tokens !== null) {
      const line: TokenLine = {
        text: `◆ ${fmt(tokens)} token  ▸ girdi ${fmt(u.input_tokens)} · önbellek ${fmt(u.cache_read_input_tokens + u.cache_creation_input_tokens)} · çıktı ${fmt(u.output_tokens)}`,
        shown: false,
      }
      tokenLines.set(e.durationMs, line)

      // Short turns may draw no TurnDuration row: then the line goes in as a plain notice
      void $.clock.sleep(1500).then(() => {
        if (!line.shown) {
          $.ui.log(line.text)
        }
      })
    } else {
      $.ui.log(`catalyst-runner: turn ended (${e.reason}) without usage`, { to: 'debug' })
    }

    return result
  })

  on('ui.render', { component: 'AbovePrompt' }, async ($, e, next) => {
    if (e.props.hasSurvey) {
      return next(e)
    }

    const { Box, Text } = $.ui.resolve(e)

    if (e.props.isWorking) {
      const r = await read($, run)

      return (
        <Box>
          <Text backgroundColor={RED} color="#ffffff" bold> ◆ RUNNER VISION </Text>
          <Text color={RED}> MOMENTUM </Text>
          <Text color={RED} bold>{meter(r.moves)}</Text>
          {r.route ? <Text dimColor>  ROUTE ▸ </Text> : null}
          {r.route ? <Text bold>{r.route}</Text> : null}
        </Box>
      )
    }

    const d = await read($, delivery)
    if (d === null) {
      return next(e)
    }

    return (
      <Box>
        <Text color={RED} bold>◆ DELIVERY COMPLETE</Text>
        <Text dimColor>  {d.seconds}s · {d.moves} moves</Text>
        {d.tokens !== null ? <Text color={YELLOW} bold>  ◆ {fmt(d.tokens)} token</Text> : null}
      </Box>
    )
  })

  on('ui.render', { component: 'Spinner' }, ($, e, next) => next({ ...e, props: { ...e.props, suffix: ' ▸▸' } }))

  on('ui.render', { component: 'TurnDuration' }, async ($, e, next) => {
    const word = PAST[Math.floor(Math.random() * PAST.length)]
    const row = next({ ...e, props: { ...e.props, word } })
    const line = findLine(e.props.durationMs)

    if (!line) {
      return row
    }

    line.shown = true
    const { Box, Text } = $.ui.resolve(e)

    return (
      <Box>
        {await row}
        <Text color={YELLOW} bold>  {line.text}</Text>
      </Box>
    )
  })
}
