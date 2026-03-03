/**
 * Sample Cypress E2E Test
 * File pattern: *.cy.ts
 * Run with: /cypress-test sample.cy.ts
 */

describe('Login Page', () => {
  beforeEach(() => {
    cy.visit('/login');
  });

  it('should display login form', () => {
    cy.get('[data-testid="login-form"]').should('be.visible');
    cy.get('[data-testid="email-input"]').should('be.visible');
    cy.get('[data-testid="password-input"]').should('be.visible');
    cy.get('[data-testid="submit-button"]').should('be.visible');
  });

  it('should show validation error for empty fields', () => {
    cy.get('[data-testid="submit-button"]').click();
    cy.get('[data-testid="error-message"]').should('contain', 'Email is required');
  });

  it('should show error for invalid credentials', () => {
    cy.get('[data-testid="email-input"]').type('wrong@example.com');
    cy.get('[data-testid="password-input"]').type('wrongpassword');
    cy.get('[data-testid="submit-button"]').click();

    cy.get('[data-testid="error-message"]')
      .should('be.visible')
      .and('contain', 'Invalid credentials');
  });

  it('should login successfully with valid credentials', () => {
    cy.get('[data-testid="email-input"]').type('user@example.com');
    cy.get('[data-testid="password-input"]').type('password123');
    cy.get('[data-testid="submit-button"]').click();

    cy.url().should('include', '/dashboard');
    cy.get('[data-testid="welcome-message"]').should('contain', 'Welcome');
  });

  it('should redirect to requested page after login', () => {
    cy.visit('/profile');
    // Should redirect to login
    cy.url().should('include', '/login');

    cy.get('[data-testid="email-input"]').type('user@example.com');
    cy.get('[data-testid="password-input"]').type('password123');
    cy.get('[data-testid="submit-button"]').click();

    // Should redirect back to profile
    cy.url().should('include', '/profile');
  });
});

describe('Dashboard', () => {
  beforeEach(() => {
    // Login via API to skip UI login
    cy.request('POST', '/api/login', {
      email: 'user@example.com',
      password: 'password123',
    }).then((response) => {
      window.localStorage.setItem('token', response.body.token);
    });
    cy.visit('/dashboard');
  });

  it('should display user stats', () => {
    cy.get('[data-testid="stats-card"]').should('have.length.at.least', 1);
  });

  it('should navigate to settings', () => {
    cy.get('[data-testid="settings-link"]').click();
    cy.url().should('include', '/settings');
  });
});
