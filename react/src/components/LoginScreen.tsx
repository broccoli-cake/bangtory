import React from 'react';

// 네이버, 카카오, 구글 SVG 아이콘 컴포넌트 (24x24로 통일)
const NaverIcon = () => (
  <svg width="24" height="24" viewBox="0 0 24 24" fill="none">
    <path d="M8.5 7H11.1L13.5 11.1V7H16.1V17H13.5L11.1 12.9V17H8.5V7Z" fill="white"/>
  </svg>
);
const KakaoIcon = () => (
  <svg width="24" height="24" viewBox="0 0 24 24" fill="none">
    <rect width="24" height="24" rx="6" fill="#FEE500"/>
    <path d="M12 6C8.13 6 5 8.48 5 11.5C5 13.36 6.47 15.01 8.7 15.8L8 18.5C8 18.5 8.03 18.5 8.06 18.5C8.22 18.5 8.36 18.44 8.47 18.33L10.62 16.29C11.07 16.38 11.53 16.43 12 16.43C15.87 16.43 19 13.95 19 10.93C19 7.91 15.87 6 12 6Z" fill="#3C1E1E"/>
  </svg>
);
const GoogleIcon = () => (
  <svg width="24" height="24" viewBox="0 0 24 24" fill="none">
    <g>
      <rect width="24" height="24" rx="6" fill="#fff"/>
      <path d="M21.805 12.223c0-.638-.057-1.252-.163-1.84H12v3.481h5.509a4.71 4.71 0 0 1-2.044 3.09v2.56h3.305c1.934-1.783 3.035-4.41 3.035-7.291z" fill="#4285F4"/>
      <path d="M12 22c2.7 0 4.97-.89 6.627-2.41l-3.305-2.56c-.917.62-2.09.99-3.322.99-2.554 0-4.72-1.724-5.495-4.042H3.09v2.54A9.997 9.997 0 0 0 12 22z" fill="#34A853"/>
      <path d="M6.505 13.978A5.997 5.997 0 0 1 6.09 12c0-.687.118-1.354.326-1.978V7.482H3.09A9.997 9.997 0 0 0 2 12c0 1.57.377 3.06 1.09 4.518l3.415-2.54z" fill="#FBBC05"/>
      <path d="M12 6.5c1.47 0 2.78.507 3.81 1.5l2.85-2.85C16.97 3.89 14.7 3 12 3A9.997 9.997 0 0 0 3.09 7.482l3.415 2.54C7.28 8.224 9.446 6.5 12 6.5z" fill="#EA4335"/>
    </g>
  </svg>
);

export default function LoginScreen({ Tomato }: { Tomato: React.FC }) {
  return (
    <div className="w-full min-h-screen flex items-center justify-center bg-gray-200 font-toss">
      <div className="relative max-w-[390px] min-h-[844px] w-full h-full bg-white border border-gray-300 shadow-2xl rounded-[24px] flex flex-col items-center justify-center px-6 py-12" style={{ boxSizing: 'border-box' }}>
        <div className="w-full flex flex-col items-center mt-8">
          <div className="flex flex-col items-center w-full mt-8 mb-8">
            <div className="text-[#F15A8A] text-4xl md:text-5xl font-toss font-bold mb-2 tracking-widest text-center leading-tight">BANGTORY</div>
            <div className="text-[#F47C7C] text-base mb-6 font-toss">룸메이트 필수 앱</div>
            <div className="mb-8"><Tomato /></div>
          </div>
          <div className="w-full flex flex-col gap-3">
            <button className="w-full flex items-center justify-center gap-2 bg-[#2DB400] text-white rounded-full py-3 font-bold text-base shadow transition active:scale-95 font-toss">
              <span className="flex items-center justify-center w-6 h-6"><NaverIcon /></span> 네이버로 이용하기
            </button>
            <button className="w-full flex items-center justify-center gap-2 bg-[#FEE500] text-black rounded-full py-3 font-bold text-base shadow transition active:scale-95 font-toss">
              <span className="flex items-center justify-center w-6 h-6"><KakaoIcon /></span> 카카오로 이용하기
            </button>
            <button className="w-full flex items-center justify-center gap-2 bg-[#F5F5F5] text-black rounded-full py-3 font-bold text-base shadow transition active:scale-95 font-toss">
              <span className="flex items-center justify-center w-6 h-6"><GoogleIcon /></span> 구글로 이용하기
            </button>
          </div>
        </div>
      </div>
    </div>
  );
} 