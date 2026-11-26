# Canvas source

These are the design boards as editable source: one `.dc.html` file per board, and `canvas.json` for the layout, pages and notes. The live canvas is the Claude Design artifact. These files are a backup and a reference for developers reading exact values.

To open a board in a browser without the canvas:

1. Rename `preview-runtime.js` to `support.js`.
2. Keep it in this folder.
3. Open any `.dc.html` file.

The runtime is a small stand-in I wrote to take the screenshots. It is not the canvas runtime, and it is not production code. Add `?preset=many&progress=1` to `Catalog.dc.html` to see the picker with apps ticked. Add `?autoplay=false` to stop the demo.

The production site and app are built from DESIGN.md and DECISIONS.md, not from these files.
