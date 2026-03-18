import { source } from '@/lib/source';
import { DocsLayout } from 'fumadocs-ui/layouts/docs';
import { baseOptions } from '@/lib/layout.shared';
import { Blocks, Braces, Code2, GitBranch } from 'lucide-react';

const sidebarIconMap = {
  Core: Blocks,
  Schema: Braces,
  Dart: Code2,
  Migrations: GitBranch,
} as const;

export default function Layout({ children }: LayoutProps<'/docs'>) {
  return (
    <DocsLayout
      tree={source.getPageTree()}
      {...baseOptions()}
      sidebar={{
        tabs: {
          transform(option) {
            const Icon = sidebarIconMap[option.title as keyof typeof sidebarIconMap];

            return {
              ...option,
              description: option.description ? (
                <span className="text-[11px] leading-4 text-fd-muted-foreground">
                  {option.description}
                </span>
              ) : undefined,
              icon: Icon ? (
                <span className="flex size-full items-center justify-center">
                  <Icon className="size-4" strokeWidth={1.9} />
                </span>
              ) : option.icon,
            };
          },
        },
      }}
    >
      {children}
    </DocsLayout>
  );
}
