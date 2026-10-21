#!/usr/bin/env python3
"""cyberdeck-tui.py — CYBERDECK MISSION CONTROL (the centerpiece).

Tabbed terminal control panel: live system/network monitoring, categorized
tool launcher with captured output, recon target book, log feed, mission
profiles and live theme info. Built on Textual; degrades gracefully to a
Rich live dashboard (`--rich-fallback` or when Textual is missing), and to
a one-shot summary when neither is available.

Keys: 1-6 tabs · / search tools · r refresh · q quit · ? help
Launch: cyberdeck   (or Super+F1 in i3)
"""
import os
import sys

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), "modules"))

BANNER = r"""
 ██████╗██╗   ██╗██████╗ ███████╗██████╗ ██████╗ ███████╗ ██████╗██╗  ██╗
██╔════╝╚██╗ ██╔╝██╔══██╗██╔════╝██╔══██╗██╔══██╗██╔════╝██╔════╝██║ ██╔╝
██║      ╚████╔╝ ██████╔╝█████╗  ██████╔╝██║  ██║█████╗  ██║     █████╔╝
╚██████╗   ██║   ██████╔╝███████╗██║  ██║██████╔╝███████╗╚██████╗██║  ██╗
 ╚═════╝   ╚═╝   ╚═════╝ ╚══════╝╚═╝  ╚═╝╚═════╝ ╚══════╝ ╚═════╝╚═╝  ╚═╝
        ◢ MISSION CONTROL // BLACKARCH OPERATIONS CONSOLE ◣
"""

THEMES = {
    "ghost": ("#00fff5", "#0a0a0a"), "matrix": ("#00ff41", "#0a0a0a"),
    "amber": ("#ffb000", "#140e04"), "blood": ("#ff0040", "#0a0002"),
}
theme_name = os.environ.get("CYBERDECK_THEME", "")
try:
    theme_name = theme_name or open(os.path.expanduser("~/.cyberdeck/theme")).read().strip()
except OSError:
    theme_name = theme_name or "ghost"
PRIMARY, BG = THEMES.get(theme_name, THEMES["ghost"])


# ── Rich fallback (also used for --once) ─────────────────────────────────
def rich_dashboard(once=False):
    from rich.columns import Columns
    from rich.console import Console
    from rich.live import Live
    from rich.panel import Panel
    from rich.text import Text
    import log_panel, network_panel, system_panel

    console = Console()

    def render():
        return Panel(Columns([system_panel.render_system_rich(), network_panel.render_network_rich()], equal=True, expand=True),
                     title=Text(BANNER.strip(), style="bold cyan"), border_style="cyan",
                     subtitle="[dim]fallback HUD — install textual for full Mission Control · Ctrl-C exits[/dim]")

    if once:
        console.print(render())
        console.print(Panel(log_panel.tail_cyberdeck_logs(25), title="◢ RECENT LOGS", border_style="dim cyan"))
        return
    try:
        with Live(render(), console=console, refresh_per_second=0.5, screen=True) as live:
            import time
            while True:
                time.sleep(2)
                live.update(render())
    except KeyboardInterrupt:
        console.print("[cyan]◢ Mission Control closed.[/cyan]")


def plain_once():
    import network_panel, system_panel
    print(BANNER)
    s, n = system_panel.get_system_stats(), network_panel.get_network_stats()
    print(f"[▓] {s['hostname']} · {s['os']} · kernel {s['kernel']} · up {s['uptime']}")
    print(f"    CPU {s['cpu_pct']}%  RAM {s['mem_pct']}%  DISK {s['disk_pct']}%")
    print(f"[●] {n['iface']} {n['local_ip']} ▸ gw {n['gateway']} ▸ pub {n['public_ip']} · tor {n['tor']}")
    print("    Install the full TUI: pip install -r tui/requirements.txt   (or rerun ./install.sh)")


# ── Textual application ───────────────────────────────────────────────────
def run_textual():
    from textual.app import App, ComposeResult
    from textual.binding import Binding
    from textual.widgets import DataTable, Footer, Header, Input, Static, TabbedContent, TabPane, TextArea
    from textual.containers import Horizontal, Vertical
    from textual.worker import WorkerState
    import log_panel, network_panel, recon_panel, system_panel, tools_panel

    CSS = f"""
    Screen {{ background: {BG}; color: #e6ffff; }}
    Header {{ background: #10161a; color: {PRIMARY}; text-style: bold; }}
    Footer {{ background: #10161a; }}
    TabbedContent {{ height: 1fr; }}
    TabPane {{ padding: 1; }}
    .panel {{ border: solid {PRIMARY}; padding: 1; height: auto; }}
    #output {{ border: solid #1a2a2a; height: 1fr; }}
    DataTable {{ border: solid #1a2a2a; height: 1fr; }}
    Input {{ border: solid {PRIMARY}; }}
    #banner {{ color: {PRIMARY}; text-style: bold; height: 8; }}
    """

    class CyberdeckApp(App):
        TITLE = "◢ CYBERDECK MISSION CONTROL"
        BINDINGS = [
            Binding("q", "quit", "Quit"),
            Binding("r", "refresh_all", "Refresh"),
            Binding("slash", "focus_search", "Search tools"),
            Binding("1", "goto_tab('tab-ops')", "Ops"),
            Binding("2", "goto_tab('tab-tools')", "Tools"),
            Binding("3", "goto_tab('tab-recon')", "Recon"),
            Binding("4", "goto_tab('tab-logs')", "Logs"),
            Binding("5", "goto_tab('tab-missions')", "Missions"),
            Binding("question_mark", "show_help", "Help"),
        ]
        _CSS = CSS

        def compose(self) -> ComposeResult:
            yield Header(show_clock=True)
            yield Static(BANNER, id="banner")
            with TabbedContent(initial="tab-ops"):
                with TabPane("◢ OPS", id="tab-ops"):
                    with Horizontal():
                        yield Static(id="sys-panel", classes="panel")
                        yield Static(id="net-panel", classes="panel")
                with TabPane("⚔ TOOLS", id="tab-tools"):
                    yield Input(placeholder="Filter tools…  (Enter a tool, then args in the box below)", id="tool-search")
                    with Horizontal():
                        table = DataTable(id="tool-table")
                        yield table
                        with Vertical():
                            yield Input(placeholder="Arguments for selected tool (optional)…", id="tool-args")
                            yield TextArea(id="output", read_only=True)
                with TabPane("⌖ RECON", id="tab-recon"):
                    yield Input(placeholder="Target domain / IP for quick lookup + save…", id="recon-input")
                    yield Static(id="recon-panel", classes="panel")
                    yield TextArea(id="recon-output", read_only=True)
                with TabPane("▤ LOGS", id="tab-logs"):
                    yield Input(placeholder="Filter logs (Enter)…", id="log-filter")
                    yield TextArea(id="log-view", read_only=True)
                with TabPane("⬢ MISSIONS", id="tab-missions"):
                    t = DataTable(id="mission-table")
                    yield t
                    yield Static("Select a mission to see its module chain. "
                                 "Run modules individually from the TOOLS tab — missions are curated checklists, "
                                 "not unattended attacks.", classes="panel")
            yield Footer()

        # CSS injection compatible across textual versions
        def on_mount(self):
            self.stylesheet.add_source(self._CSS)
            self.tools = tools_panel.discover_tools()
            self._fill_tools("")
            mission = self.query_one("#mission-table", DataTable)
            mission.add_columns("Mission profile", "Module chain")
            for name, chain in tools_panel.MISSIONS.items():
                mission.add_row(name, " ▸ ".join(f"{c}/{m}" for c, m in chain))
            self._refresh_panels()
            self.set_interval(4, self._refresh_panels)

        def _fill_tools(self, needle):
            table = self.query_one("#tool-table", DataTable)
            table.clear(columns=True)
            table.add_columns("Category", "Module", "Description")
            self._tool_paths = {}
            for cat, items in self.tools.items():
                for name, desc, path in items:
                    if needle.lower() in (cat + name + desc).lower():
                        key = table.add_row(cat, name, desc)
                        self._tool_paths[str(key)] = path
            table.cursor_type = "row"

        def _refresh_panels(self):
            try:
                self.query_one("#sys-panel", Static).update(system_panel.render_system_rich())
                self.query_one("#net-panel", Static).update(network_panel.render_network_rich())
                self.query_one("#recon-panel", Static).update(recon_panel.render_recon_rich())
                lv = self.query_one("#log-view", TextArea)
                if not lv.has_focus:
                    lv.text = log_panel.tail_cyberdeck_logs(50)
            except Exception:
                pass

        # events -------------------------------------------------------
        def on_input_changed(self, event):
            if event.input.id == "tool-search":
                self._fill_tools(event.value)

        def on_input_submitted(self, event):
            if event.input.id == "recon-input" and event.value.strip():
                target = event.value.strip()
                out = self.query_one("#recon-output", TextArea)
                out.text = recon_panel.quick_lookup(target)
                recon_panel.save_target(target, "added via TUI")
                self._refresh_panels()
            elif event.input.id == "log-filter":
                self.query_one("#log-view", TextArea).text = log_panel.grep_logs(event.value)
            elif event.input.id == "tool-args":
                self._launch_selected()

        def on_data_table_row_selected(self, event):
            if event.data_table.id == "tool-table":
                self._selected_path = self._tool_paths.get(str(event.row_key))
                self.notify(f"Selected {event.data_table.get_row(event.row_key)[1]} — set args (optional) and press Enter in the args box to run.",
                            title="Module armed")

        def _launch_selected(self):
            path = getattr(self, "_selected_path", None)
            if not path:
                self.notify("Pick a module first (click / Enter on its row).", severity="warning")
                return
            args = self.query_one("#tool-args", Input).value.split()
            out = self.query_one("#output", TextArea)
            out.text = f"▸ Running {os.path.basename(path)} {' '.join(args)} …"
            self.run_worker(lambda: tools_panel.run_tool(path, args), thread=True, name="tool-run")

        def on_worker_state_changed(self, event):
            if event.worker.name == "tool-run" and event.state == WorkerState.SUCCESS:
                rc, text = event.worker.result
                self.query_one("#output", TextArea).text = f"[exit {rc}]\n" + text[-8000:]

        # actions --------------------------------------------------------
        def action_refresh_all(self):
            self._refresh_panels()
            self.notify("Panels refreshed.", title="◢ CYBERDECK")

        def action_focus_search(self):
            self.query_one(TabbedContent).active = "tab-tools"
            self.query_one("#tool-search", Input).focus()

        def action_goto_tab(self, tab):
            self.query_one(TabbedContent).active = tab

        def action_show_help(self):
            self.notify("1-5 tabs · / search · r refresh · q quit. Tools tab: select row → args → Enter runs it with captured output. "
                        "Docs: ~/cyberdeck docs/KEYBINDINGS.md · every module supports --help.", title="Mission Control help", timeout=10)

    CyberdeckApp().run()


def main():
    if "--help" in sys.argv or "-h" in sys.argv:
        print(__doc__)
        return
    if "--once" in sys.argv:
        try:
            rich_dashboard(once=True)
        except ImportError:
            plain_once()
        return
    if "--rich-fallback" in sys.argv:
        try:
            rich_dashboard()
            return
        except ImportError:
            plain_once()
            return
    try:
        import textual  # noqa: F401
        run_textual()
    except ImportError:
        try:
            rich_dashboard()
        except ImportError:
            plain_once()


if __name__ == "__main__":
    main()
