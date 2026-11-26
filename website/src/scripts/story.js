const QUERY = "(min-width: 900px) and (min-height: 640px) and (prefers-reduced-motion: no-preference)";
const COPY_END = 0.12;
const ZOOM_START = 0.12;
const ZOOM_END = 0.6;

const clamp = (value) => Math.min(1, Math.max(0, value));
const ease = (t) => (t < 0.5 ? 4 * t * t * t : 1 - Math.pow(-2 * t + 2, 3) / 2);

export function initStory() {
  const root = document.documentElement;
  const mq = matchMedia(QUERY);
  const stage = document.querySelector(".stage");
  const pin = document.querySelector(".pin");
  const win = document.getElementById("zoomwin");
  const slot = document.getElementById("slot");
  const demo = document.getElementById("demo");
  const twin = document.getElementById("twin");
  const copy = document.querySelector(".hero-copy");
  const picker = document.getElementById("picker");
  const bar = picker.querySelector(".bar");
  let geo = null;
  let z = 0;
  let target = 0;
  let frameId = 0;
  let live = false;

  function strip(node) {
    node.removeAttribute("id");
    node.removeAttribute("name");
    node.removeAttribute("for");
    node.removeAttribute("role");
    node.removeAttribute("aria-live");
    node.removeAttribute("loading");
    node.setAttribute("tabindex", "-1");
    node.querySelectorAll("[id],[name],[for],[role],[aria-live],[loading]").forEach((child) => {
      child.removeAttribute("id");
      child.removeAttribute("name");
      child.removeAttribute("for");
      child.removeAttribute("role");
      child.removeAttribute("aria-live");
      child.removeAttribute("loading");
    });
  }

  function syncTwin() {
    const parts = Array.from(picker.children)
      .filter((el) => !el.matches(".copy-fail"))
      .map((el) => {
        const copyNode = el.cloneNode(true);
        strip(copyNode);
        return copyNode;
      });
    twin.replaceChildren(...parts);
    twin.setAttribute("inert", "");
  }

  function measure() {
    slot.style.height = "";
    const pinBox = pin.getBoundingClientRect();
    const width = pin.clientWidth - 40;
    const height = pin.clientHeight - 40;
    const slotWidth = slot.clientWidth;
    const scale = slotWidth / width;
    const slotHeight = height * scale;
    slot.style.height = `${slotHeight}px`;
    const slotBox = slot.getBoundingClientRect();
    demo.style.width = `${slotWidth}px`;
    demo.style.height = `${slotHeight}px`;
    demo.style.transform = `scale(${1 / scale})`;
    geo = { scale, x: slotBox.left - pinBox.left, y: slotBox.top - pinBox.top };
    paint();
  }

  function setLive(on) {
    if (on === live) return;
    live = on;
    picker.classList.toggle("live", on);
    pin.classList.toggle("gone", on);
    if (!on) syncTwin();
  }

  function hold() {
    if (!live) {
      picker.style.removeProperty("transform");
      bar.style.removeProperty("transform");
      return;
    }
    const lift = window.scrollY - stage.offsetTop - window.innerHeight;
    if (lift < 0) {
      picker.style.transform = `translateY(${lift}px)`;
      bar.style.transform = `translateY(${-lift}px)`;
    } else {
      picker.style.removeProperty("transform");
      bar.style.removeProperty("transform");
    }
  }

  function paint() {
    if (!geo) return;
    const e = ease(clamp((z - ZOOM_START) / (ZOOM_END - ZOOM_START)));
    const s = geo.scale + (1 - geo.scale) * e;
    win.style.transform = `translate(${(geo.x - 20) * (1 - e)}px, ${(geo.y - 20) * (1 - e)}px) scale(${s})`;
    const fade = clamp((z - ZOOM_START) / (ZOOM_END - ZOOM_START));
    twin.style.opacity = String(fade);
    demo.style.opacity = String(1 - fade);
    const away = clamp(z / COPY_END);
    copy.style.opacity = String(1 - away);
    copy.style.transform = `translateX(${-40 * away}px)`;
    setLive(z >= ZOOM_END);
    hold();
  }

  function aim() {
    target = clamp((window.scrollY - stage.offsetTop) / window.innerHeight);
    if (!frameId) frameId = requestAnimationFrame(step);
  }

  function step() {
    frameId = 0;
    z += (target - z) * 0.2;
    if (Math.abs(target - z) < 0.0005) z = target;
    paint();
    if (z !== target) frameId = requestAnimationFrame(step);
  }

  function reveal() {
    if (z >= 1) return;
    window.scrollTo({ top: picker.offsetTop - 20, behavior: "instant" });
    z = 1;
    target = 1;
    paint();
  }

  function on() {
    root.classList.add("story-on");
    syncTwin();
    measure();
    z = target = clamp((window.scrollY - stage.offsetTop) / window.innerHeight);
    paint();
  }

  function off() {
    root.classList.remove("story-on");
    live = false;
    picker.classList.remove("live");
    picker.style.removeProperty("transform");
    bar.style.removeProperty("transform");
    pin.classList.remove("gone");
    for (const el of [win, demo, twin, copy, slot]) el.removeAttribute("style");
    twin.replaceChildren();
  }

  function sync() {
    if (mq.matches) on();
    else off();
  }

  window.addEventListener("scroll", () => {
    if (!root.classList.contains("story-on")) return;
    aim();
  }, { passive: true });
  window.addEventListener("resize", () => {
    if (root.classList.contains("story-on")) {
      measure();
      aim();
    }
  });
  picker.addEventListener("focusin", (event) => {
    if (!root.classList.contains("story-on") || z >= 1) return;
    const focused = event.target;
    if (live && !focused.matches(":focus-visible")) return;
    reveal();
    focused.scrollIntoView({ block: "nearest" });
  });
  mq.addEventListener("change", sync);
  sync();
}
