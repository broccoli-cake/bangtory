import React from 'react';

interface TomatoProfileProps {
  size?: number;
  active?: boolean;
  index?: number;
  onClick?: () => void;
  style?: React.CSSProperties;
}

// index별로 표정/색상 다르게, active면 테두리 강조
export default function TomatoProfile({ size = 44, active = false, index = 0, onClick, style }: TomatoProfileProps) {
  // 색상/표정 프리셋
  const tomatoColors = ['#FA2E55', '#FF6F61', '#FFBABA', '#FF7C7C'];
  const faces = [
    // 기본 웃는 얼굴
    <g key="smile"><ellipse cx="20" cy="28" rx="6" ry="3" fill="#fff" opacity=".7"/><ellipse cx="20" cy="28" rx="3" ry="1.5" fill="#191F28" opacity=".5"/></g>,
    // 윙크
    <g key="wink"><ellipse cx="20" cy="28" rx="6" ry="3" fill="#fff" opacity=".7"/><rect x="17" y="27" width="6" height="2" rx="1" fill="#191F28" opacity=".5"/></g>,
    // 놀람
    <g key="surprise"><ellipse cx="20" cy="28" rx="6" ry="3" fill="#fff" opacity=".7"/><circle cx="20" cy="28" r="1.5" fill="#191F28" opacity=".5"/></g>,
    // 하트
    <g key="heart"><ellipse cx="20" cy="28" rx="6" ry="3" fill="#fff" opacity=".7"/><text x="16" y="30" fontSize="6" fill="#FA2E55">❤</text></g>,
  ];
  const color = tomatoColors[index % tomatoColors.length];
  const face = faces[index % faces.length];
  return (
    <div style={{ width: size, height: size, borderRadius: '50%', background: active ? '#FFF0F4' : '#F2F4F6', border: active ? '2px solid #FA2E55' : '2px solid #E5E8EB', display: 'flex', alignItems: 'center', justifyContent: 'center', cursor: 'pointer', ...style }} onClick={onClick}>
      <svg width={size} height={size} viewBox="0 0 40 40" fill="none">
        <circle cx="20" cy="20" r="16" fill={color} stroke={active ? '#FA2E55' : '#fff'} strokeWidth={active ? 3 : 2} />
        {/* 꼭지 */}
        <rect x="17" y="6" width="6" height="8" rx="3" fill="#8B95A1" />
        {/* 얼굴 */}
        {face}
      </svg>
    </div>
  );
} 