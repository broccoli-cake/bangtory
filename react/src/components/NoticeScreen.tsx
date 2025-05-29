import React, { useState } from 'react';

const notices = [
  {
    id: 1,
    title: '서비스 이용약관 변경 안내',
    content: '서비스 이용약관이 변경되었습니다. 자세한 내용은 공지사항을 참고해 주세요.'
  },
  {
    id: 2,
    title: '업데이트 안내',
    content: '업데이트되었습니다.\n\n*방토리*의 채팅 기능 업데이트에 관해 안내드립니다.'
  },
  {
    id: 3,
    title: '방토리를 소개합니다',
    content: '방토리 서비스에 오신 것을 환영합니다!'
  },
  {
    id: 4,
    title: '이용 약관 주의사항',
    content: '이용 약관을 꼭 확인해 주세요.'
  },
  {
    id: 5,
    title: '문의하기',
    content: '문의는 support@bangtory.com 으로 보내주세요.'
  },
];

export default function NoticeScreen({ onBack }: { onBack?: () => void }) {
  const [selected, setSelected] = useState<number | null>(null);
  const notice = notices.find(n => n.id === selected);

  return (
    <div className="w-full min-h-screen flex items-center justify-center bg-[#F9FAFB] font-toss">
      <div className="max-w-[390px] min-h-[844px] h-[844px] w-full bg-white shadow-2xl rounded-[24px] flex flex-col overflow-hidden relative">
        {/* 상단 헤더 */}
        <div className="flex items-center justify-between px-4 pt-6 pb-2 bg-white z-10 border-b border-[#F2F4F6]">
          <button onClick={selected !== null ? () => setSelected(null) : onBack} className="text-[#191F28] text-2xl px-2" aria-label="뒤로가기">←</button>
          <div className="flex-1 text-center text-lg font-bold text-[#191F28]">공지사항</div>
          <div className="w-8" />
        </div>
        {/* 공지 리스트/상세 */}
        {selected === null ? (
          <div className="flex-1 px-4 py-4 space-y-2">
            {notices.map(n => (
              <button key={n.id} className="w-full flex items-center justify-between px-4 py-4 text-sm text-[#191F28] font-medium bg-[#F9FAFB] rounded-xl border border-[#F2F4F6] hover:bg-[#FA2E55]/10 transition" onClick={() => setSelected(n.id)}>
                {n.title}
                <span className="material-icons text-base text-[#8B95A1]">chevron_right</span>
              </button>
            ))}
          </div>
        ) : (
          <div className="flex-1 px-4 py-4">
            <div className="bg-[#F9FAFB] rounded-xl border border-[#F2F4F6] p-6">
              <div className="text-lg font-bold text-[#191F28] mb-4">{notice?.title}</div>
              <div className="text-sm text-[#191F28] whitespace-pre-line">{notice?.content}</div>
            </div>
          </div>
        )}
      </div>
    </div>
  );
} 