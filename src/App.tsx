
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
  return (
    <div className="site-shell">
      <header className="navbar">
        <a className="brand" href="#home" aria-label="SightAI home">
          <span className="brand-icon">S</span>
          <span>Sight<span className="brand-accent">AI</span></span>
        </a>

        <nav className="nav-links" aria-label="Main navigation">
          <a href="#features">Features</a>
          <a href="#how-it-works">How it works</a>
          <a href="#mission">Our mission</a>
        </nav>

        <a className="nav-cta" href="#features">
          Discover SightAI <span aria-hidden="true">↗</span>
        </a>
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
                  <span className="mini-brand">S</span> SightAI
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
            <div className="mission-mark">S<span>AI</span></div>
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
            <span className="brand-icon">S</span>
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
