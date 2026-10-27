import { expect, test } from 'claude-code/testing'

test('a finished turn logs its token line', async ($, on) => {
  const logs: string[] = []
  on('ui.log', (_, e) => { logs.push(e.text); return { value: undefined } })
  on('clock.now', () => ({ value: 1000 }))
  on('clock.sleep', () => ({ value: undefined }))
  on('turn.complete', () => ({ text: '' }))

  await $.turn.complete({
    reason: 'answer', answer: 'ok', durationMs: 3000, isAborted: false, turnId: 't1',
    usage: { model: 'claude-opus-5-5', input_tokens: 1200, output_tokens: 1700, cache_read_input_tokens: 40000, cache_creation_input_tokens: 5300 },
  } as any)

  await new Promise(r => setTimeout(r, 20))
  expect(logs.join('\n')).toContain('48.2K token')
})

test('usage handed back by core is used when the event has none', async ($, on) => {
  const logs: string[] = []
  on('ui.log', (_, e) => { logs.push(e.text); return { value: undefined } })
  on('clock.now', () => ({ value: 1000 }))
  on('clock.sleep', () => ({ value: undefined }))
  on('turn.complete', () => ({
    text: '',
    usage: { model: 'claude-opus-5-5', input_tokens: 500, output_tokens: 500, cache_read_input_tokens: 0, cache_creation_input_tokens: 0 },
  }))

  await $.turn.complete({ reason: 'answer', answer: 'ok', durationMs: 3000, isAborted: false, turnId: 't2' } as any)

  await new Promise(r => setTimeout(r, 20))
  expect(logs.join('\n')).toContain('1.0K token')
})

test('the token line is drawn in the turn-end row', async ($, on) => {
  on('ui.log', () => ({ value: undefined }))
  on('clock.now', () => ({ value: 1000 }))
  on('clock.sleep', () => new Promise(() => {}))
  on('turn.complete', () => ({ text: '' }))
  on('ui.render', ($, e) => {
    const { Text } = $.ui.resolve(e)

    return <Text>Wallran for 12s</Text>
  })

  await $.turn.complete({
    reason: 'answer', answer: 'ok', durationMs: 12000, isAborted: false, turnId: 't3',
    usage: { model: 'claude-opus-5-5', input_tokens: 1200, output_tokens: 1700, cache_read_input_tokens: 40000, cache_creation_input_tokens: 5300 },
  } as any)

  const ui = await $.ui.mount({ plugin: 'catalyst-runner', component: 'TurnDuration', surface: 'terminal', props: { word: 'Baked', durationMs: 12000 } } as any)
  const row = await ui.find({ type: 'Text', text: /48\.2K token/ })
  expect(row?.text).toContain('girdi 1.2K')
  await ui.unmount()
})

test('a session takes the tab district and switches the theme to it', async ($, on) => {
  const set: unknown[] = []
  const toasts: string[] = []
  on('env.get', () => ({ value: 'anchor' }))
  on('env.set', () => ({ value: {} }))
  on('config.set', (_, e) => { set.push(e); return { value: (e as any).value } })
  on('ui.toast', (_, e) => { toasts.push(e.text); return { value: undefined } })
  on('session.start', (_, e) => ({ cwd: e.cwd }))

  await $.session.start({ cwd: '/', surface: 'terminal', isInteractive: true })

  expect(JSON.stringify(set)).toContain('custom:catalyst-anchor')
  expect(toasts.join()).toContain('ANCHOR')
})
