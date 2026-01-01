import { useState, useEffect } from 'react';
import { Target, Users, Trophy, ArrowRight, ChevronDown, Zap, Mail } from 'lucide-react';

function App() {
  const [countdown, setCountdown] = useState({ days: 0, hours: 0, mins: 0, secs: 0 });
  const [email, setEmail] = useState('');
  const [submitted, setSubmitted] = useState(false);

  // Countdown to Jan 15, 2026
  useEffect(() => {
    const target = new Date('2026-01-15T00:00:00').getTime();

    const update = () => {
      const now = Date.now();
      const diff = target - now;

      if (diff > 0) {
        setCountdown({
          days: Math.floor(diff / (1000 * 60 * 60 * 24)),
          hours: Math.floor((diff % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60)),
          mins: Math.floor((diff % (1000 * 60 * 60)) / (1000 * 60)),
          secs: Math.floor((diff % (1000 * 60)) / 1000),
        });
      }
    };

    update();
    const interval = setInterval(update, 1000);
    return () => clearInterval(interval);
  }, []);

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (email) {
      setSubmitted(true);
      setEmail('');
    }
  };

  return (
    <div>
      <div className="grain" />

      {/* Marquee */}
      <div className="marquee">
        <span>
          THE WORLD'S FIRST STREAK-BASED SOCIAL RUNNING CLUB • JOIN THE SQUAD • DEPLOYING JAN 2026 • ⚡ COLLECT XP • STAY ON FIRE •&nbsp;
          THE WORLD'S FIRST STREAK-BASED SOCIAL RUNNING CLUB • JOIN THE SQUAD • DEPLOYING JAN 2026 • ⚡ COLLECT XP • STAY ON FIRE •&nbsp;
        </span>
      </div>

      {/* Hero */}
      <section className="hero">
        <div className="hero-bg" />
        <div className="hero-tag">Issue #01 • Jan 2026</div>
        <h1 className="hero-title">ran.</h1>
        <p className="hero-subtitle">
          The world's first <strong>streak-based</strong> social running club.
          Share your missions. Duel your friends. Stay on fire.
        </p>
        <button className="btn-primary" onClick={() => document.getElementById('signup')?.scrollIntoView({ behavior: 'smooth' })}>
          DEPLOY MISSION
        </button>

        <div className="scroll-indicator">
          <span style={{ fontSize: 10, textTransform: 'uppercase', letterSpacing: '0.2em' }}>Scroll</span>
          <ChevronDown size={20} />
        </div>
      </section>

      {/* Countdown */}
      <section className="countdown-section">
        <div className="countdown-label">TestFlight Launch Countdown</div>
        <div className="countdown-grid">
          <div className="countdown-item">
            <div className="countdown-value">{countdown.days}</div>
            <div className="countdown-unit">Days</div>
          </div>
          <div className="countdown-item">
            <div className="countdown-value">{countdown.hours}</div>
            <div className="countdown-unit">Hours</div>
          </div>
          <div className="countdown-item">
            <div className="countdown-value">{countdown.mins}</div>
            <div className="countdown-unit">Minutes</div>
          </div>
          <div className="countdown-item">
            <div className="countdown-value">{countdown.secs}</div>
            <div className="countdown-unit">Seconds</div>
          </div>
        </div>

        {/* Progress Bar */}
        <div className="progress-container">
          <div className="progress-label-row">
            <span>SYSTEM INITIALIZATION</span>
            <span>86%</span>
          </div>
          <div className="progress-track">
            <div className="progress-fill" style={{ width: '86%' }}></div>
          </div>
          <div className="progress-status">OPTIMIZING NEURAL PATHWAYS [████████░░]</div>
        </div>
      </section>

      {/* Stats */}
      <section className="stats-section">
        <div className="container">
          <div className="stats-grid">
            <div className="streak-card">
              <div className="streak-number">14</div>
              <div className="streak-label">DAY STREAK</div>
              <span className="streak-badge">BKK RANK #01</span>
            </div>

            <div className="stats-content">
              <h2>The Squad Protocol</h2>
              <p>
                Running is stale. Missions are eternal. Join a squad, duel your
                rivals in real-time combat, and turn every calorie burned into
                XP for your global ranking.
              </p>
              <div className="stats-row">
                <div className="stat-item">
                  <span className="stat-value">2.4M</span>
                  <span className="stat-label">Missions Logged</span>
                </div>
                <div className="stat-item">
                  <span className="stat-value">12K</span>
                  <span className="stat-label">Heroes Active</span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* Features */}
      <section className="features-section">
        <div className="container">
          <h2 className="features-title">OBJECTIVES</h2>
          <div className="features-grid">
            <div className="feature-card">
              <div className="feature-icon">
                <Target size={32} />
              </div>
              <h3 className="feature-title">SNAKE RUNS</h3>
              <p className="feature-desc">
                Dynamic distance tracking with real-time speed lines and hero power auras.
              </p>
              <div className="feature-link">
                Learn More <ArrowRight size={16} />
              </div>
            </div>

            <div className="feature-card">
              <div className="feature-icon">
                <Users size={32} />
              </div>
              <h3 className="feature-title">DUEL MODE</h3>
              <p className="feature-desc">
                Health-bar combat with your closest rivals. Their progress is your damage.
              </p>
              <div className="feature-link">
                Learn More <ArrowRight size={16} />
              </div>
            </div>

            <div className="feature-card">
              <div className="feature-icon">
                <Trophy size={32} color="#000" />
              </div>
              <h3 className="feature-title">THE VAULT</h3>
              <p className="feature-desc">
                50+ unique badges for side quests and legendary feats. Gold, Silver, Bronze.
              </p>
              <div className="feature-link">
                Learn More <ArrowRight size={16} />
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* Signup */}
      <section className="signup-section" id="signup">
        <Zap size={48} style={{ marginBottom: 24, opacity: 0.3 }} />
        <h2 className="signup-title">GET EARLY ACCESS</h2>
        <p className="signup-subtitle">
          {submitted
            ? "You're on the list! We'll notify you when TestFlight opens."
            : "Be the first to know when TestFlight slots open."}
        </p>
        {!submitted && (
          <form className="signup-form" onSubmit={handleSubmit}>
            <input
              type="email"
              className="signup-input"
              placeholder="Enter your email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              required
            />
            <button type="submit" className="signup-btn">
              <Mail size={18} style={{ marginRight: 8, verticalAlign: 'middle' }} />
              Notify Me
            </button>
          </form>
        )}
      </section>

      {/* CTA */}
      <section className="cta-section">
        <h2 className="cta-title">READY?</h2>
        <p className="cta-subtitle">Deploying January 2026</p>
        <button className="btn-secondary" onClick={() => document.getElementById('signup')?.scrollIntoView({ behavior: 'smooth' })}>
          Reserve Hero Tag <ArrowRight size={20} style={{ marginLeft: 12, verticalAlign: 'middle' }} />
        </button>
      </section>

      {/* Footer */}
      <footer className="footer">
        <div className="footer-content">
          <div className="footer-logo">ran.</div>
          <div className="footer-links">
            <a href="#">Archives</a>
            <a href="#">Privacy</a>
            <a href="#">Terms</a>
          </div>
          <div className="footer-copy">© 2026 Bangkok Running Club HQ</div>
        </div>
      </footer>
    </div>
  );
}

export default App;
