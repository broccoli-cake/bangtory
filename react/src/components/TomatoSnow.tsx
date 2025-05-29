import React from 'react';

export default function TomatoSnow() {
  // 토마토 눈(작은 원)들의 속성 배열
  const snows = [
    { cx: 10, cy: 60, r: 7, delay: '0s', color: '#FFBABA', anim: 'snow1' },
    { cx: 140, cy: 50, r: 5, delay: '0.3s', color: '#FF7C7C', anim: 'snow2' },
    { cx: 30, cy: 100, r: 4, delay: '0.6s', color: '#FF5A5A', anim: 'snow3' },
    { cx: 120, cy: 110, r: 6, delay: '0.1s', color: '#FFBABA', anim: 'snow4' },
    { cx: 80, cy: 30, r: 5, delay: '0.5s', color: '#FF7C7C', anim: 'snow5' },
  ];
  return (
    <svg className="w-40 h-40" viewBox="0 0 160 160" fill="none">
      {snows.map((s, i) => (
        <circle
          key={i}
          cx={s.cx}
          cy={s.cy}
          r={s.r}
          fill={s.color}
          style={{
            opacity: 0.8,
            animation: `${s.anim} 2.5s infinite alternate`,
            animationDelay: s.delay,
          }}
        />
      ))}
      <style>{`
        @keyframes snow1 { 0%{transform:translateY(0)} 100%{transform:translateY(-12px) scale(1.1);} }
        @keyframes snow2 { 0%{transform:translateY(0)} 100%{transform:translateY(10px) scale(0.9);} }
        @keyframes snow3 { 0%{transform:translateX(0)} 100%{transform:translateX(-10px) scale(1.2);} }
        @keyframes snow4 { 0%{transform:translateX(0)} 100%{transform:translateX(12px) scale(0.8);} }
        @keyframes snow5 { 0%{transform:scale(1)} 100%{transform:scale(1.3);} }
      `}</style>
    </svg>
  );
} 