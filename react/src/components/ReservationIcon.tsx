import React from 'react';

export type ReservationType = 'bath' | 'laundry' | 'visitor' | 'add';

export default function ReservationIcon({ type, className = '' }: { type: ReservationType; className?: string }) {
  if (type === 'bath') {
    // 욕실: 귀여운 욕조
    return (
      <svg width="36" height="36" viewBox="0 0 36 36" fill="none" className={className}>
        <rect x="7" y="20" width="22" height="8" rx="4" fill="#FFBABA" />
        <rect x="10" y="24" width="16" height="4" rx="2" fill="#FA2E55" />
        <ellipse cx="18" cy="20" rx="10" ry="4" fill="#fff" opacity=".7" />
        <rect x="24" y="10" width="2" height="8" rx="1" fill="#8B95A1" />
        <circle cx="25" cy="10" r="2" fill="#8B95A1" />
      </svg>
    );
  }
  if (type === 'laundry') {
    // 세탁기: 원형+문
    return (
      <svg width="36" height="36" viewBox="0 0 36 36" fill="none" className={className}>
        <circle cx="18" cy="20" r="10" fill="#FFBABA" />
        <circle cx="18" cy="20" r="6" fill="#fff" opacity=".7" />
        <circle cx="18" cy="20" r="3" fill="#FA2E55" />
        <rect x="13" y="10" width="10" height="4" rx="2" fill="#8B95A1" />
      </svg>
    );
  }
  if (type === 'visitor') {
    // 방문객: 문
    return (
      <svg width="36" height="36" viewBox="0 0 36 36" fill="none" className={className}>
        <rect x="10" y="12" width="16" height="16" rx="4" fill="#FFBABA" />
        <rect x="16" y="20" width="4" height="8" rx="2" fill="#FA2E55" />
        <circle cx="22" cy="20" r="1" fill="#8B95A1" />
      </svg>
    );
  }
  // 추가
  return (
    <svg width="36" height="36" viewBox="0 0 36 36" fill="none" className={className}>
      <rect x="8" y="8" width="20" height="20" rx="10" fill="#fff" stroke="#D1D6DB" strokeDasharray="4 2" />
      <text x="18" y="24" textAnchor="middle" fontSize="20" fill="#FA2E55">＋</text>
    </svg>
  );
} 