const FRAME_MS = 450;
const FRAMES = 33;
const TICKS = [1, 2, 4, 5, 7];
const INSTALL = ["Firefox", "Slack", "Visual Studio Code", "Zoom", "Spotify"];

export function initDemo() {
  const scenes = Array.from(document.querySelectorAll(".scene"));
  const steps = document.getElementById("steps");
  const stepItems = Array.from(steps.querySelectorAll("li"));
  const play = document.getElementById("play");
  const rows = Array.from(document.querySelectorAll(".d-row"));
  const bar = document.getElementById("d-bar");
  const dCount = document.getElementById("d-count");
  const dDone = document.getElementById("d-done");
  const dFill = document.getElementById("d-fill");
  const dWho = document.getElementById("d-who");
  const checks = Array.from(document.querySelectorAll("#d-check p"));
  const installRows = Array.from(document.querySelectorAll("#d-install li"));
  const unRows = Array.from(document.querySelectorAll("#d-un li"));
  const tickOrder = ["firefox", "slack", "visual-studio-code", "zoom", "spotify"];
  let frame = 0;
  let timer = 0;
  let running = false;

  function setSt(el, text, cls) {
    const st = el.querySelector(".st");
    st.textContent = text;
    st.className = `st ${cls}`.trim();
  }

  function setMini(el, ratio) {
    el.querySelector(".d-mini i").style.transform = `scaleX(${ratio})`;
  }

  function render() {
    const f = frame;
    const scene = f <= 8 ? 0 : f <= 24 ? 1 : 2;
    scenes.forEach((el, i) => el.classList.toggle("on", i === scene));
    steps.dataset.step = String(scene);
    stepItems.forEach((el, i) => el.classList.toggle("on", i === scene));

    const n = TICKS.filter((at) => at <= f).length;
    rows.forEach((row) => {
      const index = tickOrder.indexOf(row.dataset.token);
      row.classList.toggle("on", index !== -1 && index < n);
    });
    dCount.textContent = `${n} ${n === 1 ? "app" : "apps"} selected`;
    bar.classList.toggle("has", n > 0);
    bar.classList.toggle("press", f === 8);

    const active = f >= 24 ? 5 : Math.floor((f - 9) / 3);
    const phase = (f - 9) % 3;
    const done = f >= 24 ? 5 : Math.max(0, active);
    dDone.textContent = `${done} of 5 done`;
    dFill.style.transform = `scaleX(${done / 5})`;
    installRows.forEach((row, i) => {
      row.classList.toggle("active", f >= 9 && f < 24 && i === active);
      if (f < 9 || i > active) {
        setSt(row, "Waiting", "");
        setMini(row, 0);
      } else if (i < active || f >= 24) {
        setSt(row, "Done", "done");
        setMini(row, 1);
      } else if (phase === 0) {
        setSt(row, "Downloading", "");
        setMini(row, 0.45);
      } else {
        setSt(row, "Verifying", "go");
        setMini(row, 1);
      }
    });
    const who = Math.min(Math.max(active, 0), 4);
    dWho.textContent = INSTALL[who];
    const ok = f >= 24 ? 3 : phase === 0 ? 0 : phase === 1 ? 2 : 3;
    checks.forEach((el, i) => el.classList.toggle("ok", i < ok));

    unRows.forEach((row, i) => {
      const removing = f >= 27 && f <= 30 && i === 2;
      row.classList.toggle("active", removing);
      row.classList.toggle("gone", f >= 31 && i === 2);
      const small = row.querySelector("small");
      if (i === 2) {
        small.textContent = removing ? "Removing leftovers…" : "Installed by SettleIn";
        row.querySelector(".d-ub").style.visibility = removing ? "hidden" : "";
        setMini(row, removing ? (f - 26) / 4 : 0);
      }
    });
  }

  function tick() {
    frame = (frame + 1) % FRAMES;
    render();
  }

  function setRunning(on) {
    running = on;
    clearInterval(timer);
    if (on) timer = setInterval(tick, FRAME_MS);
    play.textContent = on ? "Pause demo" : "Play demo";
  }

  play.addEventListener("click", () => setRunning(!running));
  render();
  setRunning(!matchMedia("(prefers-reduced-motion: reduce)").matches);
}
