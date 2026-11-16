
import { useEffect, useState } from 'react'
import './App.css'

const features = [
  {
    number: '01',
    icon: '◉',
    title: 'AI Image Descriptions',
    description:
      'Understand the world around you with AI-generated descriptions of images and everyday surroundings.',
  },
  {
    number: '02',
    icon: '⌗',
    title: 'Simple Camera Access',
    description:
      'Capture a photo or choose one from your gallery to get started in just a few taps.',
  },
  {
    number: '03',
    icon: '◖',
    title: 'Blind Mode',
    description:
      'Access a dedicated experience designed around the needs of people with visual impairments.',
  },
]

function App() {
  const [theme, setTheme] = useState<'light' | 'dark'>(() => {
    const savedTheme = localStorage.getItem('sightai-theme')
    return savedTheme === 'dark' ? 'dark' : 'light'
  })

  useEffect(() => {
    document.documentElement.style.colorScheme = theme
    localStorage.setItem('sightai-theme', theme)
  }, [theme])

  const toggleTheme = () => {
    setTheme((currentTheme) => (currentTheme === 'light' ? 'dark' : 'light'))
  }

  return (
    <div className="site-shell" data-theme={theme}>
      <header className="navbar">
        <a className="brand" href="#home" aria-label="SightAI home">
          <img className="brand-icon" src={`${import.meta.env.BASE_URL}sightai-logo.png`} alt="" />
          <span>Sight<span className="brand-accent">AI</span></span>
        </a>

        <nav className="nav-links" aria-label="Main navigation">
          <a href="#features">Features</a>
          <a href="#how-it-works">How it works</a>
          <a href="#mission">Our mission</a>
        </nav>

        <div className="nav-actions">
          <a
            className="github-link"
            href="https://github.com/gabecodez/sightai"
            target="_blank"
            rel="noopener noreferrer"
            aria-label="SightAI on GitHub (opens in a new tab)"
          >
            <svg viewBox="0 0 24 24" aria-hidden="true">
              <path fill="currentColor" d="M12 .9a11.1 11.1 0 0 0-3.51 21.63c.56.1.76-.24.76-.54v-2.1c-3.1.67-3.76-1.32-3.76-1.32-.5-1.29-1.24-1.63-1.24-1.63-1.01-.69.08-.68.08-.68 1.12.08 1.71 1.15 1.71 1.15 1 .1.74 2.05 3.63 1.46.1-.72.39-1.21.7-1.49-2.48-.28-5.09-1.24-5.09-5.52 0-1.22.44-2.22 1.15-3-.12-.28-.5-1.42.11-2.96 0 0 .94-.3 3.05 1.14a10.6 10.6 0 0 1 5.55 0c2.11-1.44 3.05-1.14 3.05-1.14.61 1.54.23 2.68.11 2.96.72.78 1.15 1.78 1.15 3 0 4.29-2.61 5.23-5.1 5.51.4.35.75 1.02.75 2.06v3.06c0 .3.2.65.77.54A11.1 11.1 0 0 0 12 .9Z" />
            </svg>
            <span>GitHub</span>
          </a>
          <button
            className="theme-toggle"
            type="button"
            onClick={toggleTheme}
            aria-label={`Switch to ${theme === 'light' ? 'dark' : 'light'} mode`}
            title={`Switch to ${theme === 'light' ? 'dark' : 'light'} mode`}
          >
            {theme === 'light' ? (
              <svg viewBox="0 0 24 24" aria-hidden="true">
                <path d="M12 3v2m0 14v2M3 12h2m14 0h2M5.64 5.64l1.42 1.42m9.88 9.88 1.42 1.42m0-12.72-1.42 1.42m-9.88 9.88-1.42 1.42" />
                <circle cx="12" cy="12" r="4" />
              </svg>
            ) : (
              <svg viewBox="0 0 24 24" aria-hidden="true">
                <path d="M20.2 15.2A8.5 8.5 0 0 1 8.8 3.8 8.6 8.6 0 1 0 20.2 15.2Z" />
              </svg>
            )}
          </button>
          <a className="nav-cta" href="#features">
            Discover SightAI <span aria-hidden="true">↗</span>
          </a>
        </div>
      </header>

      <main>
        <section className="hero section-container" id="home">
          <div className="hero-copy">
            <div className="eyebrow">
              <span className="status-dot" />
              AI-powered accessibility
            </div>

            <h1>
              A clearer view
              <br />
              of <span className="text-gradient">the world.</span>
            </h1>

            <p className="hero-description">
              SightAI helps people with visual impairments better understand
              their surroundings through AI-powered image descriptions and
              accessibility-focused tools.
            </p>

            <div className="hero-actions">
              <a className="button button-primary" href="#how-it-works">
                Explore how it works <span aria-hidden="true">→</span>
              </a>
              <a className="button button-secondary" href="#mission">
                Our mission
              </a>
            </div>

            <div className="hero-note">
              <span className="note-icon">✓</span>
              Built with accessibility in mind
            </div>
          </div>

          <div className="hero-visual" aria-label="SightAI app concept">
            <div className="visual-glow" />

            <div className="floating-label label-top">
              <span className="label-symbol">✳</span>
              AI-powered descriptions
            </div>

            <div className="phone">
              <div className="phone-top">
                <span className="phone-brand">
                  <img className="mini-brand" src={`${import.meta.env.BASE_URL}sightai-logo.png`} alt="" />
                </span>
                <span className="phone-menu">•••</span>
              </div>

              <div className="phone-image">
                <div className="scene-sky" />
                <div className="scene-sun" />
                <div className="scene-mountain mountain-back" />
                <div className="scene-mountain mountain-front" />
                <div className="scene-ground" />
                <div className="scene-path" />
                <div className="scene-tree tree-left">
                  <span />
                </div>
                <div className="scene-tree tree-right">
                  <span />
                </div>
                <div className="scan-corner corner-tl" />
                <div className="scan-corner corner-tr" />
                <div className="scan-corner corner-bl" />
                <div className="scan-corner corner-br" />
                <span className="image-caption">IMAGE PREVIEW</span>
              </div>

              <div className="phone-result">
                <div className="result-heading">
                  <span className="result-icon">✳</span>
                  <span>Image description</span>
                  <span className="result-badge">AI</span>
                </div>
                <p>
                  A peaceful outdoor path surrounded by greenery, with
                  mountains in the distance.
                </p>
              </div>

              <div className="phone-bottom">
                <span className="phone-tab active-tab">◉<small>Camera</small></span>
                <span className="phone-tab">◎<small>Settings</small></span>
              </div>
            </div>

            <div className="floating-label label-bottom">
              <span className="label-check">✓</span>
              Designed for accessibility
            </div>

            <span className="decor decor-one" />
            <span className="decor decor-two" />
            <span className="decor decor-three" />
          </div>
        </section>

        <section className="trust-strip">
          <div className="section-container trust-inner">
            <span>TECHNOLOGY WITH A PURPOSE</span>
            <p>Making digital experiences more accessible, one step at a time.</p>
          </div>
        </section>

        <section className="features section-container" id="features">
          <div className="section-heading">
            <span className="section-kicker">WHAT SIGHTAI OFFERS</span>
            <h2>
              More understanding.
              <br />
              <span className="muted-heading">Fewer barriers.</span>
            </h2>
            <p>
              Thoughtful tools designed to help make everyday visual
              information easier to understand.
            </p>
          </div>

          <div className="feature-grid">
            {features.map((feature) => (
              <article className="feature-card" key={feature.number}>
                <div className="feature-card-top">
                  <span className="feature-icon">{feature.icon}</span>
                  <span className="feature-number">{feature.number}</span>
                </div>
                <h3>{feature.title}</h3>
                <p>{feature.description}</p>
                <a href="#how-it-works" className="feature-link">
                  Learn more <span aria-hidden="true">↗</span>
                </a>
              </article>
            ))}
          </div>
        </section>

        <section className="how-section" id="how-it-works">
          <div className="section-container how-layout">
            <div className="section-heading how-heading">
              <span className="section-kicker">HOW IT WORKS</span>
              <h2>
                Simple steps.
                <br />
                <span className="muted-heading">Meaningful help.</span>
              </h2>
              <p>
                SightAI aims to make getting information from an image a
                straightforward experience.
              </p>
            </div>

            <div className="steps">
              <article className="step">
                <span className="step-number">01</span>
                <div>
                  <h3>Capture or select</h3>
                  <p>
                    Take a picture with the camera or choose an existing image
                    from your gallery.
                  </p>
                </div>
              </article>
              <article className="step">
                <span className="step-number">02</span>
                <div>
                  <h3>Generate a description</h3>
                  <p>
                    Use AI-powered image description to help interpret the
                    visual information in your image.
                  </p>
                </div>
              </article>
              <article className="step">
                <span className="step-number">03</span>
                <div>
                  <h3>Explore accessibly</h3>
                  <p>
                    Use the app's available tools and Blind Mode for an
                    experience designed with accessibility in mind.
                  </p>
                </div>
              </article>
            </div>
          </div>
        </section>

        <section className="mission section-container" id="mission">
          <div className="mission-card">
            <img className="mission-mark" src={`${import.meta.env.BASE_URL}sightai-logo.png`} alt="SightAI logo" />
            <div className="mission-copy">
              <span className="section-kicker">OUR MISSION</span>
              <h2>Technology should open doors, not create barriers.</h2>
              <p>
                SightAI is an accessibility-focused project exploring how
                artificial intelligence can help people with visual
                impairments access and understand visual information.
              </p>
            </div>
            <div className="mission-decoration" aria-hidden="true">
              <span />
              <span />
              <span />
              <span />
              <span />
            </div>
          </div>
        </section>
      </main>

      <footer className="footer">
        <div className="section-container footer-inner">
          <a className="brand footer-brand" href="#home">
            <img className="brand-icon" src={`${import.meta.env.BASE_URL}sightai-logo.png`} alt="" />
            <span>Sight<span className="brand-accent">AI</span></span>
          </a>
          <p>Designed with accessibility in mind.</p>
          <a href="#home" className="back-to-top">
            Back to top ↑
          </a>
        </div>
        <div className="section-container footer-bottom">
          <span>© {new Date().getFullYear()} SightAI</span>
          <span>AI-powered accessibility project</span>
        </div>
      </footer>
    </div>
  )
}

export default App
