/**
 * @license MIT
 * topbar 2.0.0, 2023-02-04
 * https://buunguyen.github.io/topbar
 * Copyright (c) 2021 Buu Nguyen
 */
function createTopbar(window, document) {
  "use strict";

  // https://gist.github.com/paulirish/1579671
  (function () {
    let lastTime = 0;
    const vendors = ["ms", "moz", "webkit", "o"];

    for (let index = 0; index < vendors.length && !window.requestAnimationFrame; index += 1) {
      const vendor = vendors[index];
      window.requestAnimationFrame = window[`${vendor}RequestAnimationFrame`];
      window.cancelAnimationFrame =
        window[`${vendor}CancelAnimationFrame`] || window[`${vendor}CancelRequestAnimationFrame`];
    }

    if (!window.requestAnimationFrame) {
      window.requestAnimationFrame = (callback) => {
        const currentTime = new Date().getTime();
        const timeToCall = Math.max(0, 16 - (currentTime - lastTime));
        const id = window.setTimeout(() => callback(currentTime + timeToCall), timeToCall);
        lastTime = currentTime + timeToCall;
        return id;
      };
    }

    if (!window.cancelAnimationFrame) {
      window.cancelAnimationFrame = (id) => {
        clearTimeout(id);
      };
    }
  })();

  let canvas;
  let currentProgress;
  let showing;
  let progressTimerId = null;
  let fadeTimerId = null;
  let delayTimerId = null;

  const addEvent = (elem, type, handler) => {
    if (elem.addEventListener) {
      elem.addEventListener(type, handler, false);
    } else if (elem.attachEvent) {
      elem.attachEvent(`on${type}`, handler);
    } else {
      elem[`on${type}`] = handler;
    }
  };

  const options = {
    autoRun: true,
    barThickness: 3,
    barColors: {
      0: "rgba(26,  188, 156, .9)",
      ".25": "rgba(52,  152, 219, .9)",
      ".50": "rgba(241, 196, 15,  .9)",
      ".75": "rgba(230, 126, 34,  .9)",
      "1.0": "rgba(211, 84,  0,   .9)"
    },
    shadowBlur: 10,
    shadowColor: "rgba(0,   0,   0,   .6)",
    className: null
  };

  const repaint = () => {
    canvas.width = window.innerWidth;
    canvas.height = options.barThickness * 5; // need space for shadow

    const context = canvas.getContext("2d");
    context.shadowBlur = options.shadowBlur;
    context.shadowColor = options.shadowColor;

    const lineGradient = context.createLinearGradient(0, 0, canvas.width, 0);
    Object.keys(options.barColors).forEach((stop) => {
      lineGradient.addColorStop(stop, options.barColors[stop]);
    });

    context.lineWidth = options.barThickness;
    context.beginPath();
    context.moveTo(0, options.barThickness / 2);
    context.lineTo(Math.ceil(currentProgress * canvas.width), options.barThickness / 2);
    context.strokeStyle = lineGradient;
    context.stroke();
  };

  const createCanvas = () => {
    canvas = document.createElement("canvas");
    const style = canvas.style;
    style.position = "fixed";
    style.top = "0";
    style.left = "0";
    style.right = "0";
    style.margin = "0";
    style.padding = "0";
    style.zIndex = 100001;
    style.display = "none";

    if (options.className) {
      canvas.classList.add(options.className);
    }

    document.body.appendChild(canvas);
    addEvent(window, "resize", repaint);
  };

  const topbar = {
    config(opts) {
      if (!opts) return;

      Object.keys(opts).forEach((key) => {
        if (Object.prototype.hasOwnProperty.call(options, key)) {
          options[key] = opts[key];
        }
      });
    },
    show(delay) {
      if (showing) return;

      if (delay) {
        if (delayTimerId) return;
        delayTimerId = window.setTimeout(() => topbar.show(), delay);
        return;
      }

      showing = true;
      if (fadeTimerId !== null) window.cancelAnimationFrame(fadeTimerId);
      if (!canvas) createCanvas();
      canvas.style.opacity = "1";
      canvas.style.display = "block";
      topbar.progress(0);

      if (options.autoRun) {
        const loop = () => {
          progressTimerId = window.requestAnimationFrame(loop);
          topbar.progress(`+${0.05 * Math.pow(1 - Math.sqrt(currentProgress), 2)}`);
        };
        loop();
      }
    },
    progress(to) {
      if (typeof to === "undefined") return currentProgress;

      let nextValue = to;
      if (typeof to === "string") {
        const base = to.includes("+") || to.includes("-") ? currentProgress : 0;
        nextValue = base + parseFloat(to);
      }

      currentProgress = nextValue > 1 ? 1 : nextValue;
      repaint();
      return currentProgress;
    },
    hide() {
      window.clearTimeout(delayTimerId);
      delayTimerId = null;
      if (!showing) return;
      showing = false;

      if (progressTimerId !== null) {
        window.cancelAnimationFrame(progressTimerId);
        progressTimerId = null;
      }

      const loop = () => {
        if (topbar.progress("+.1") >= 1) {
          const nextOpacity = parseFloat(canvas.style.opacity) - 0.05;
          canvas.style.opacity = `${nextOpacity}`;
          if (nextOpacity <= 0.05) {
            canvas.style.display = "none";
            fadeTimerId = null;
            return;
          }
        }

        fadeTimerId = window.requestAnimationFrame(loop);
      };

      loop();
    }
  };

  if (typeof window !== "undefined") {
    window.topbar = topbar;
  }

  return topbar;
}

const topbar = createTopbar(window, document);

export default topbar;
