# Contributing to CMS Collaboration Platform

Thank you for your interest in contributing! Here are some guidelines to help you get started.

## Development Setup

1. Fork the repository
2. Clone your fork:
   ```bash
   git clone https://github.com/YOUR_USERNAME/CMS_with_Collaberation-.git
   ```
3. Run the setup script:
   ```bash
   chmod +x setup.sh && ./setup.sh
   ```

## Project Structure

- `frontend/` - React TypeScript application
- `backend/` - ASP.NET Core C# Web API
- `php-server/` - PHP Slim Framework server
- `database/` - Database schemas and migrations
- `docker/` - Docker configuration

## Coding Standards

### Frontend (TypeScript/React)
- Use TypeScript for all new code
- Follow React best practices and hooks patterns
- Use functional components
- Format code with Prettier
- Follow ESLint rules

### Backend (C#)
- Follow C# naming conventions (PascalCase for public members)
- Use async/await for asynchronous operations
- Write XML documentation comments for public APIs
- Follow SOLID principles

### PHP
- Follow PSR-12 coding standards
- Use type hints and return types
- Write PHPDoc comments
- Use dependency injection

## Git Workflow

1. Create a feature branch:
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. Make your changes and commit:
   ```bash
   git add .
   git commit -m "feat: add your feature description"
   ```

3. Push to your fork:
   ```bash
   git push origin feature/your-feature-name
   ```

4. Create a Pull Request

## Commit Message Format

Follow conventional commits:

- `feat:` - New feature
- `fix:` - Bug fix
- `docs:` - Documentation changes
- `style:` - Code style changes (formatting)
- `refactor:` - Code refactoring
- `test:` - Test changes
- `chore:` - Build process or auxiliary tool changes

Example:
```
feat: add real-time cursor tracking
fix: resolve SignalR connection timeout
docs: update API documentation
```

## Testing

- Write unit tests for new features
- Ensure all tests pass before submitting PR
- Frontend: `npm test`
- Backend: `dotnet test`
- PHP: `composer test`

## Pull Request Process

1. Update the README.md with details of changes if needed
2. Update documentation for any API changes
3. Ensure your code follows the style guidelines
4. Link any related issues in the PR description
5. Wait for review and address feedback

## Code Review

All submissions require review. We'll review your PR and may request changes. Common review points:

- Code quality and maintainability
- Performance implications
- Security considerations
- Test coverage
- Documentation completeness

## Bug Reports

When filing a bug report, include:

- Clear title and description
- Steps to reproduce
- Expected vs actual behavior
- Screenshots if applicable
- Environment details (OS, browser, versions)

## Feature Requests

For feature requests, describe:

- The problem you're trying to solve
- Proposed solution
- Alternative solutions considered
- Impact on existing features

## Questions?

- Open an issue with the `question` label
- Check existing issues and documentation first

## License

By contributing, you agree that your contributions will be licensed under the MIT License.
