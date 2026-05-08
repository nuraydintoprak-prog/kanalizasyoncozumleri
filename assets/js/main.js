(() => {
  "use strict";

  // Mobile menu toggle
  const toggle = document.querySelector(".menu-toggle");
  const nav = document.querySelector(".nav");
  if (toggle && nav) {
    toggle.addEventListener("click", () => {
      const isOpen = nav.classList.toggle("open");
      toggle.setAttribute("aria-expanded", isOpen ? "true" : "false");
    });
    nav.querySelectorAll(".has-sub > a").forEach(link => {
      link.addEventListener("click", e => {
        if (window.matchMedia("(max-width: 720px)").matches) {
          e.preventDefault();
          link.parentElement.classList.toggle("open");
        }
      });
    });
  }

  // Year in footer
  const y = document.querySelector("[data-year]");
  if (y) y.textContent = new Date().getFullYear();

  // Web3Forms submission
  const form = document.querySelector("form.contact-form");
  if (form) {
    const status = form.querySelector(".form-status");
    form.addEventListener("submit", async (e) => {
      e.preventDefault();
      const accessKey = form.querySelector('input[name="access_key"]').value;
      if (!accessKey || accessKey.startsWith("YOUR_")) {
        status.className = "form-status err";
        status.textContent = "Form henüz aktive edilmedi. Lütfen telefonla ulaşın: 0552 007 60 34";
        return;
      }
      status.className = "form-status";
      status.textContent = "Gönderiliyor...";
      const data = new FormData(form);
      try {
        const res = await fetch("https://api.web3forms.com/submit", {
          method: "POST",
          body: data
        });
        const json = await res.json();
        if (json.success) {
          status.className = "form-status ok";
          status.textContent = "Talebiniz alındı. Ekibimiz en kısa sürede sizi arayacak.";
          form.reset();
        } else {
          status.className = "form-status err";
          status.textContent = "Bir sorun oluştu. Lütfen telefonla ulaşın: 0552 007 60 34";
        }
      } catch {
        status.className = "form-status err";
        status.textContent = "Bağlantı hatası. Lütfen telefonla ulaşın: 0552 007 60 34";
      }
    });
  }

  // Smooth scroll for in-page anchors
  document.querySelectorAll('a[href^="#"]').forEach(a => {
    a.addEventListener("click", e => {
      const id = a.getAttribute("href");
      if (id.length > 1) {
        const el = document.querySelector(id);
        if (el) {
          e.preventDefault();
          el.scrollIntoView({ behavior: "smooth", block: "start" });
        }
      }
    });
  });
})();
