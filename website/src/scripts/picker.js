export function initPicker() {
  const picker = document.getElementById("picker");
  const boxes = Array.from(picker.querySelectorAll('input[name="app"]'));
  const byToken = new Map(boxes.map((box) => [box.value, box]));
  const cats = Array.from(picker.querySelectorAll(".cat")).map((el) => ({
    box: el.querySelector(".cat-box"),
    toggle: el.querySelector(".cat-toggle"),
    name: el.querySelector("h3").textContent,
    apps: Array.from(el.querySelectorAll('input[name="app"]')),
  }));
  const count = document.getElementById("count");
  const tally = document.getElementById("tally");
  const slots = document.getElementById("slots");
  const download = document.getElementById("download");
  const copy = document.getElementById("copy");
  const copyLabel = document.getElementById("copy-label");
  const copyTick = copy.querySelector(".tick");
  const copyStatus = document.getElementById("copy-status");
  const copyFail = document.getElementById("copy-fail");
  const copyField = document.getElementById("copy-field");
  const selectAll = document.getElementById("select-all");
  const deselectAll = document.getElementById("deselect-all");
  const notice = document.getElementById("notice");
  const shown = new Set();
  let copyTimer = 0;

  function ticked() {
    return boxes.filter((box) => box.checked);
  }

  function renderSlots(list) {
    slots.replaceChildren();
    if (list.length === 0) {
      for (let i = 0; i < 3; i += 1) {
        const empty = document.createElement("span");
        empty.className = "slot-i empty";
        slots.append(empty);
      }
      shown.clear();
      return;
    }
    const visible = list.length > 8 ? list.slice(0, 7) : list;
    const current = new Set(list.map((box) => box.value));
    for (const token of Array.from(shown)) if (!current.has(token)) shown.delete(token);
    for (const box of visible) {
      const img = document.createElement("img");
      img.className = "slot-i";
      img.src = `/icons/${box.value}-128.png`;
      img.width = 32;
      img.height = 32;
      img.alt = "";
      if (!shown.has(box.value)) img.classList.add("pop");
      slots.append(img);
    }
    for (const token of current) shown.add(token);
    if (list.length > visible.length) {
      const more = document.createElement("span");
      more.className = "slot-more";
      more.textContent = `+${list.length - visible.length}`;
      slots.append(more);
    }
  }

  function update() {
    const list = ticked();
    const n = list.length;
    count.textContent = `${n} ${n === 1 ? "app" : "apps"} selected`;
    tally.classList.toggle("has", n > 0);
    download.hidden = n === 0;
    copy.hidden = n === 0;
    renderSlots(list);
    for (const cat of cats) {
      const all = cat.apps.every((box) => box.checked);
      cat.box.checked = all;
      cat.toggle.textContent = all ? "Deselect all" : "Select all";
      cat.box.setAttribute("aria-label", `${all ? "Deselect all" : "Select all"} in ${cat.name}`);
    }
    selectAll.disabled = n === boxes.length;
    deselectAll.disabled = n === 0;
  }

  function writeAddress() {
    const list = ticked().map((box) => box.value);
    const params = new URLSearchParams(location.search);
    params.delete("apps");
    const query = [params.toString(), list.length ? `apps=${list.join(",")}` : ""]
      .filter(Boolean)
      .join("&");
    const next = `${location.pathname}${query ? `?${query}` : ""}${location.hash}`;
    if (next !== `${location.pathname}${location.search}${location.hash}`) {
      history.replaceState(history.state, "", next);
    }
  }

  function changed() {
    update();
    writeAddress();
    resetCopy();
  }

  function showNotice(left) {
    notice.replaceChildren();
    if (left === 0) return;
    const text = document.createElement("p");
    text.textContent =
      left === 1
        ? "This link named 1 app SettleIn no longer offers, so it was left out."
        : `This link named ${left} apps SettleIn no longer offers, so they were left out.`;
    const dismiss = document.createElement("button");
    dismiss.className = "btn";
    dismiss.type = "button";
    dismiss.textContent = "Dismiss";
    dismiss.addEventListener("click", () => notice.replaceChildren());
    notice.append(text, dismiss);
  }

  function readAddress(announce) {
    const wanted = new Set(
      (new URLSearchParams(location.search).get("apps") ?? "").split(",").filter(Boolean),
    );
    boxes.forEach((box) => {
      box.checked = wanted.has(box.value);
    });
    let left = 0;
    for (const token of wanted) if (!byToken.has(token)) left += 1;
    if (announce) showNotice(left);
    update();
    writeAddress();
  }

  function setAll(on) {
    boxes.forEach((box) => {
      box.checked = on;
    });
    changed();
  }

  function resetCopy() {
    clearTimeout(copyTimer);
    copy.classList.remove("copied");
    copyTick.setAttribute("hidden", "");
    copyLabel.textContent = "Copy link";
    copyFail.hidden = true;
    copyStatus.textContent = "";
  }

  async function copyLink() {
    const url = location.href;
    try {
      await navigator.clipboard.writeText(url);
    } catch {
      copyField.value = url;
      copyFail.hidden = false;
      copyStatus.textContent = "Couldn’t copy. Press and hold the link to copy it.";
      copyField.focus();
      copyField.select();
      return;
    }
    copyFail.hidden = true;
    copy.classList.add("copied");
    copyTick.removeAttribute("hidden");
    copyLabel.textContent = "Link copied";
    copyStatus.textContent = "Link copied";
    clearTimeout(copyTimer);
    copyTimer = setTimeout(resetCopy, 2000);
  }

  picker.addEventListener("change", (event) => {
    const target = event.target;
    if (target.classList.contains("cat-box")) {
      const cat = cats.find((item) => item.box === target);
      cat.apps.forEach((box) => {
        box.checked = target.checked;
      });
    }
    changed();
  });
  selectAll.addEventListener("click", () => setAll(true));
  deselectAll.addEventListener("click", () => setAll(false));
  copy.addEventListener("click", copyLink);
  download.addEventListener("click", () => {
    const list = ticked().map((box) => box.value);
    location.href = `${download.dataset.afterDownload}?apps=${list.join(",")}`;
  });
  window.addEventListener("pageshow", (event) => {
    if (event.persisted) readAddress(false);
  });

  readAddress(true);
}
