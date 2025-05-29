import React from 'react';

function TomatoSnow() {
  const snows = [
    { cx: 10, cy: 60, r: 7, delay: '0s', color: '#FFBABA', anim: 'snow1' },
    { cx: 140, cy: 50, r: 5, delay: '0.3s', color: '#FF7C7C', anim: 'snow2' },
    { cx: 30, cy: 100, r: 4, delay: '0.6s', color: '#FF5A5A', anim: 'snow3' },
    { cx: 120, cy: 110, r: 6, delay: '0.1s', color: '#FFBABA', anim: 'snow4' },
    { cx: 80, cy: 30, r: 5, delay: '0.5s', color: '#FF7C7C', anim: 'snow5' },
  ];
  return (
    <svg className="absolute left-0 top-0 w-40 h-40 pointer-events-none" viewBox="0 0 160 160" fill="none">
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

export function Tomato() {
  return (
    <div className="relative w-40 h-40 flex items-center justify-center">
      <TomatoSnow />
      <svg
        className="w-40 h-40 animate-tomato"
        viewBox="0 0 160 160"
        fill="none"
        xmlns="http://www.w3.org/2000/svg"
      >
        <ellipse cx="80" cy="95" rx="60" ry="50" fill="#FF5A5A" />
        <ellipse cx="80" cy="110" rx="40" ry="25" fill="#FF7C7C" />
        <ellipse cx="80" cy="80" rx="50" ry="40" fill="#FF7C7C" />
        <ellipse cx="80" cy="100" rx="30" ry="18" fill="#FFBABA" />
        <path d="M80 55 C85 40, 105 40, 100 60" stroke="#4CAF50" strokeWidth="6" fill="none" />
        <path d="M80 55 C75 40, 55 40, 60 60" stroke="#4CAF50" strokeWidth="6" fill="none" />
        <circle cx="70" cy="90" r="5" fill="#fff" opacity="0.7" />
        <circle cx="95" cy="100" r="3" fill="#fff" opacity="0.5" />
      </svg>
    </div>
  );
}

export default function OnboardingScreen() {
  return (
    <div className="w-full min-h-screen flex items-center justify-center bg-gray-200 font-toss">
      <div
        className="relative max-w-[390px] min-h-[844px] w-full h-full bg-gradient-to-b from-[#F15A8A] to-[#F47C7C] border border-gray-300 shadow-2xl rounded-[24px] flex flex-col items-center justify-center px-6 py-12"
        style={{ boxSizing: 'border-box' }}
      >
        <div className="flex-1 flex flex-col justify-center items-center w-full">
          <div className="mb-10 w-full">
            <p className="text-white text-3xl md:text-4xl font-light text-center leading-snug animate-fade-in font-toss">
              함께하는 공간이
              <br />
              <br />즐거워지는 시간,
            </p>
            <br />
            <p className="text-white text-4xl md:text-5xl font-extrabold text-center mt-4 animate-bounce font-toss">
              방 토 리
            </p>
          </div>
          <div className="flex justify-center w-full mt-8">
            <Tomato />
          </div>
        </div>
        <style>{`
          .animate-fade-in {
            animation: fadeIn 1.2s 0.2s both;
          }
          @keyframes fadeIn {
            from { opacity: 0; }
            to { opacity: 1; }
          }
          .animate-bounce {
            animation: bounce 1.2s infinite alternate cubic-bezier(.68,-0.55,.27,1.55);
          }
          @keyframes bounce {
            0% { transform: translateY(0); }
            100% { transform: translateY(-10px); }
          }
          .animate-tomato {
            animation: tomatoSquish 2.2s infinite cubic-bezier(.68,-0.55,.27,1.55);
            transform-origin: 50% 80%;
          }
          @keyframes tomatoSquish {
            0% { transform: scale(1,1) rotate(-2deg); }
            10% { transform: scale(1.08,0.92) rotate(2deg); }
            20% { transform: scale(0.95,1.05) rotate(-3deg); }
            30% { transform: scale(1.1,0.9) rotate(3deg); }
            40% { transform: scale(0.98,1.02) rotate(-2deg); }
            50% { transform: scale(1.05,0.95) rotate(2deg); }
            60% { transform: scale(1,1) rotate(0deg); }
            100% { transform: scale(1,1) rotate(-2deg); }
          }
        `}</style>
      </div>
    </div>
  );
} 