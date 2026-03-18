import type { BaseLayoutProps } from 'fumadocs-ui/layouts/shared';

export const gitConfig = {
  user: 'serezhia',
  repo: 'comon_orm',
  branch: 'main',
};

export function baseOptions(): BaseLayoutProps {
  return {
    nav: {
      title: (
        <div className="flex items-center gap-3">
          <span className="flex h-8 w-8 items-center justify-center rounded-xl border border-[color:var(--color-fd-border)] bg-[color:var(--color-fd-card)] text-sm font-semibold text-[color:var(--color-fd-primary)] shadow-sm">
            co
          </span>
          <span
            className="text-sm font-semibold tracking-[-0.03em] text-[color:var(--color-fd-foreground)]"
            style={{ fontFamily: 'var(--font-display), sans-serif' }}
          >
            comon_orm
          </span>
        </div>
      ),
    },
    githubUrl: `https://github.com/${gitConfig.user}/${gitConfig.repo}`,
  };
}
