export const NotificationPlugin = async ({ project, client, $, directory, worktree }) => {
  return {
    event: async ({ event }) => {
      // Send notification on session completion
      if (event.type === "session.idle") {
        // Play sound notification
        await $`powershell.exe -Command "(New-Object Media.SoundPlayer 'D:\\02 Areas\\04 Coding Tools\\open_code_completed.wav').PlaySync()"`
        // Send toast notification
        await $`powershell.exe -Command "New-BurntToastNotification -Text 'Open Code', 'Completed'"`
      }
    },
  }
}
