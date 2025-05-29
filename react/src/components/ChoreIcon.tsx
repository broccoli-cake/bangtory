import React from 'react';

type ChoreType = 'clean' | 'trash' | 'dish';

export default function ChoreIcon({ type, className = '' }: { type: ChoreType; className?: string }) {
  if (type === 'clean') {
    // 빗자루
    return (
      <svg width="36" height="36" viewBox="0 0 36 36" fill="none" className={className}>
        <rect x="16" y="4" width="4" height="16" rx="2" fill="#8B95A1" />
        <rect x="12" y="20" width="12" height="8" rx="4" fill="#FA2E55" />
        <ellipse cx="18" cy="30" rx="6" ry="2" fill="#FFBABA" />
      </svg>
    );
  }
  if (type === 'trash') {
    // 분리수거통
    return (
      <svg width="36" height="36" viewBox="0 0 36 36" fill="none" className={className}>
        <rect x="10" y="12" width="16" height="16" rx="4" fill="#FFBABA" />
        <rect x="14" y="8" width="8" height="6" rx="2" fill="#8B95A1" />
        <rect x="16" y="16" width="4" height="8" rx="2" fill="#FA2E55" />
      </svg>
    );
  }
  // 설거지
  return (
    <svg width="36" height="36" viewBox="0 0 36 36" fill="none" className={className}>
      <circle cx="18" cy="18" r="12" fill="#FFBABA" />
      <ellipse cx="18" cy="18" rx="8" ry="4" fill="#fff" opacity=".7" />
      <rect x="16" y="10" width="4" height="8" rx="2" fill="#FA2E55" />
    </svg>
  );
} 