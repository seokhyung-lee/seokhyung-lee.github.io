// get the ninja-keys element
const ninja = document.querySelector('ninja-keys');

// add the home and posts menu items
ninja.data = [{
    id: "nav-about",
    title: "about",
    section: "Navigation",
    handler: () => {
      window.location.href = "/";
    },
  },{id: "nav-publications",
          title: "publications",
          description: "Peer-reviewed publications and arXiv preprints.Google Scholar | ORCID | SciRate",
          section: "Navigation",
          handler: () => {
            window.location.href = "/publications/";
          },
        },{id: "nav-repositories",
          title: "repositories",
          description: "Edit the `_data/repositories.yml` and change the `github_users` and `github_repos` lists to include your own GitHub profile and repositories.",
          section: "Navigation",
          handler: () => {
            window.location.href = "/repositories/";
          },
        },{id: "nav-cv",
          title: "cv",
          description: "For more details, please see the attached PDF file.",
          section: "Navigation",
          handler: () => {
            window.location.href = "/cv/";
          },
        },{id: "news-i-will-give-a-long-talk-at-the-aqis-2024-conference-26-30-aug-sapporo-japan-at-11-00-am-gmt-9-on-26-aug-it-will-be-about-my-recent-work-on-decoding-color-codes",
          title: 'I will give a long talk at the AQIS 2024 conference (26-30 Aug,...',
          description: "",
          section: "News",},{id: "news-my-new-preprint-low-overhead-magic-state-distillation-with-color-codes-is-out-in-this-work-we-propose-two-resource-efficient-msd-schemes-for-2d-color-codes-based-on-the-15-to-1-msd-circuit-and-lattice-surgery",
          title: 'My new preprint “Low-overhead magic state distillation with color codes” is out! In...',
          description: "",
          section: "News",},{id: "news-i-wrote-an-article-titled-색-부호를-활용한-결함허용-양자컴퓨팅-fault-tolerant-quantum-computing-with-the-color-code-for-the-korean-magazine-물리학과-첨단기술-physics-and-high-technology-the-article-provides-a-brief-introduction-to-fault-tolerant-quantum-computing-using-the-color-code-if-you-re-interested-and-can-read-korean-take-a-look",
          title: 'I wrote an article titled “색 부호를 활용한 결함허용 양자컴퓨팅 (Fault-Tolerant Quantum Computing...',
          description: "",
          section: "News",},{id: "news-my-paper-color-code-decoder-with-improved-scaling-for-correcting-circuit-level-noise-has-been-published-in-quantum-it-introduces-a-color-code-decoder-that-can-correct-circuit-level-noise-achieving-better-sub-threshold-scaling-compared-to-existing-matching-based-decoders",
          title: 'My paper “Color code decoder with improved scaling for correcting circuit-level noise” has...',
          description: "",
          section: "News",},{id: "news-major-update-to-our-paper-low-overhead-magic-state-distillation-with-color-codes-magic-state-cultivation-is-now-integrated-in-our-two-level-scheme-achieving-significant-performance-improvement",
          title: 'Major update to our paper “Low-overhead magic state distillation with color codes”! Magic...',
          description: "",
          section: "News",},{id: "news-my-paper-low-overhead-magic-state-distillation-with-color-codes-has-been-published-in-prx-quantum",
          title: 'My paper “Low-Overhead Magic State Distillation with Color Codes” has been published in...',
          description: "",
          section: "News",},{id: "news-i-joined-sungkyunkwan-university-skku-suwon-south-korea-in-september-2025-as-an-assistant-professor-in-the-department-of-quantum-information-engineering-i-am-excited-to-begin-building-my-own-research-group",
          title: 'I joined Sungkyunkwan University (SKKU) (Suwon, South Korea) in September 2025 as an...',
          description: "",
          section: "News",},{id: "news-my-new-paper-efficient-post-selection-for-general-quantum-ldpc-codes-with-lucas-english-and-stephen-bartlett-is-out-we-introduce-a-new-post-selection-method-for-qldpc-codes-that-significantly-reduces-the-logical-error-rate-by-orders-of-magnitude-overcoming-the-generalizability-and-efficiency-issues-of-the-conventional-logical-gap-method",
          title: 'My new paper “Efficient Post-Selection for General Quantum LDPC Codes” with Lucas English...',
          description: "",
          section: "News",},{
        id: 'social-scholar',
        title: 'Google Scholar',
        section: 'Socials',
        handler: () => {
          window.open("https://scholar.google.com/citations?user=NURGJAwAAAAJ", "_blank");
        },
      },{
      id: 'light-theme',
      title: 'Change theme to light',
      description: 'Change the theme of the site to Light',
      section: 'Theme',
      handler: () => {
        setThemeSetting("light");
      },
    },
    {
      id: 'dark-theme',
      title: 'Change theme to dark',
      description: 'Change the theme of the site to Dark',
      section: 'Theme',
      handler: () => {
        setThemeSetting("dark");
      },
    },
    {
      id: 'system-theme',
      title: 'Use system default theme',
      description: 'Change the theme of the site to System Default',
      section: 'Theme',
      handler: () => {
        setThemeSetting("system");
      },
    },];
