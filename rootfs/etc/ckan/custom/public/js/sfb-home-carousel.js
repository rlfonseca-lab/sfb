(function () {
  function initCarousel(root) {
    const track = root.querySelector(".sfb-carousel__track");
    const dots = Array.from(root.querySelectorAll("[data-sfb-dot]"));
    const prev = root.querySelector("[data-sfb-prev]");
    const next = root.querySelector("[data-sfb-next]");
    const total = dots.length;

    let idx = 0;

    function render() {
      track.style.transform = "translateX(" + (-idx * 100) + "%)";
      dots.forEach((d, i) => d.classList.toggle("is-active", i === idx));
    }

    prev.addEventListener("click", function () {
      idx = (idx - 1 + total) % total;
      render();
    });

    next.addEventListener("click", function () {
      idx = (idx + 1) % total;
      render();
    });

    dots.forEach((d, i) => {
      d.addEventListener("click", function () {
        idx = i;
        render();
      });
    });

    render();
  }

  document.addEventListener("DOMContentLoaded", function () {
    document.querySelectorAll("[data-sfb-carousel]").forEach(initCarousel);
  });
})();
