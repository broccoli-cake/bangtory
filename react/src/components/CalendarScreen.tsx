import React, { useState } from 'react';
import ReservationIcon from './ReservationIcon';
import ChoreIcon from './ChoreIcon';

// MainScreen에서 사용한 ScreenType 타입 정의 복사
// (실제 프로젝트에서는 별도 파일로 분리 추천)
type ScreenType = 'onboarding' | 'roomSelect' | 'roomCreate' | 'loading' | 'main' | 'timetable' | 'calendar' | 'chat' | 'settings';

const days = ['일', '월', '화', '수', '목', '금', '토'];

// 예시 일정 데이터
const events = [
  {
    id: '1',
    type: 'visitor',
    icon: <ReservationIcon type="visitor" className="w-6 h-6" />,
    color: '#8B95A1',
    title: '방문객 예약',
    time: '15:00~18:00',
    desc: '김민영 (2/4명) - 확인완료',
    date: '2025-05-01',
  },
  {
    id: '2',
    type: 'laundry',
    icon: <ReservationIcon type="laundry" className="w-6 h-6" />,
    color: '#FFBABA',
    title: '세탁기 예약',
    time: '17:00~18:00',
    desc: '홍수한 (1/4명) - 대기',
    date: '2025-05-02',
  },
  {
    id: '3',
    type: 'bath',
    icon: <ReservationIcon type="bath" className="w-6 h-6" />,
    color: '#FA2E55',
    title: '욕실 예약',
    time: '12:00~13:00',
    desc: '최현경 (0/4명) - 대기',
    date: '2025-05-08',
  },
  {
    id: '4',
    type: 'chore',
    icon: <ChoreIcon type="clean" className="w-6 h-6" />,
    color: '#5AC4FF',
    title: '청소 당번',
    time: '오전',
    desc: '담당: 김민영 - 완료',
    date: '2025-05-01',
  },
  {
    id: '5',
    type: 'chore',
    icon: <ChoreIcon type="dish" className="w-6 h-6" />,
    color: '#FFD600',
    title: '설거지 당번',
    time: '저녁',
    desc: '담당: 민수연 - 미완료',
    date: '2025-05-03',
  },
  // ...더 추가 가능
];

function getMonthMatrix(year: number, month: number) {
  const firstDay = new Date(year, month, 1);
  const lastDay = new Date(year, month + 1, 0);
  const matrix = [];
  let week = [];
  let dayOfWeek = firstDay.getDay();
  // 앞 빈칸
  for (let i = 0; i < dayOfWeek; i++) week.push(null);
  for (let d = 1; d <= lastDay.getDate(); d++) {
    week.push(new Date(year, month, d));
    if (week.length === 7) {
      matrix.push(week);
      week = [];
    }
  }
  if (week.length) {
    while (week.length < 7) week.push(null);
    matrix.push(week);
  }
  return matrix;
}

export default function CalendarScreen({ onBack, setCurrentScreen }: { onBack?: () => void; setCurrentScreen?: (screen: ScreenType) => void }) {
  const [year, setYear] = useState(2025);
  const [month, setMonth] = useState(0); // 0: January
  const [selected, setSelected] = useState('2025-01-02');
  const matrix = getMonthMatrix(year, month);
  const selectedEvents = events.filter(e => e.date === selected);

  return (
    <div className="w-full min-h-screen flex items-center justify-center bg-[#F9FAFB] font-toss">
      <div className="max-w-[390px] min-h-[844px] h-[844px] w-full bg-white shadow-2xl rounded-[24px] flex flex-col overflow-hidden relative">
        {/* 상단 헤더 */}
        <div className="flex items-center justify-between px-4 pt-6 pb-2 bg-white z-10">
          <button onClick={onBack} className="text-[#191F28] text-2xl px-2" aria-label="뒤로가기">←</button>
          <div className="flex-1 text-center text-lg font-bold text-[#191F28]">캘린더</div>
          <div className="w-8" />
        </div>
        {/* 월/연도 네비 */}
        <div className="flex items-center justify-center gap-4 px-4 mb-2">
          <button className="w-8 h-8 flex items-center justify-center text-[#8B95A1] text-xl" onClick={() => setMonth(m => m === 0 ? 11 : m - 1)}>&lt;</button>
          <div className="flex flex-col items-center">
            <span className="text-base font-bold text-[#191F28]">{year}년 {month + 1}월</span>
          </div>
          <button className="w-8 h-8 flex items-center justify-center text-[#8B95A1] text-xl" onClick={() => setMonth(m => m === 11 ? 0 : m + 1)}>&gt;</button>
        </div>
        {/* 달력 */}
        <div className="px-4 pb-2">
          <div className="bg-[#F9FAFB] rounded-xl p-2 border border-[#F2F4F6] mb-2 overflow-x-hidden">
            <div className="grid grid-cols-7 gap-0 w-full">
              {days.map((d, i) => (
                <div key={i} className="text-xs text-[#8B95A1] font-bold text-center py-1">{d}</div>
              ))}
              {matrix.flat().map((date, i) => {
                if (!date) return <div key={i} className="h-10" />;
                const ymd = date.toISOString().slice(0, 10);
                const hasEvent = events.some(e => e.date === ymd);
                const isSelected = selected === ymd;
                return (
                  <button
                    key={i}
                    className={`h-10 w-full flex flex-col items-center justify-center rounded-full relative ${isSelected ? 'bg-[#FA2E55] text-white font-bold' : 'bg-transparent text-[#191F28]'}`}
                    onClick={() => setSelected(ymd)}
                  >
                    <span>{date.getDate()}</span>
                    {hasEvent && <span className="w-1.5 h-1.5 rounded-full bg-[#FA2E55] mt-0.5" />}
                  </button>
                );
              })}
            </div>
          </div>
        </div>
        {/* 선택 날짜 정보 */}
        <div className="px-4">
          <div className="flex items-center gap-2 mb-2">
            <span className="w-2 h-2 rounded-full bg-[#FA2E55]" />
            <span className="text-xs text-[#FA2E55] font-bold">{selected && new Date(selected).toLocaleDateString('ko-KR', { year: 'numeric', month: 'long', day: 'numeric', weekday: 'long' })}</span>
          </div>
          <div className="flex flex-col gap-2">
            {selectedEvents.length === 0 && (
              <div className="text-sm text-[#8B95A1] text-center py-8">일정이 없습니다</div>
            )}
            {selectedEvents.map(ev => (
              <div key={ev.id} className="rounded-xl border-l-4 flex items-center gap-3 px-4 py-3 mb-2" style={{ borderColor: ev.color, background: '#fff' }}>
                <div>{ev.icon}</div>
                <div className="flex-1">
                  <div className="flex items-center gap-2">
                    <div className="text-xs text-[#8B95A1]">{ev.time}</div>
                    <div className="text-xs font-bold" style={{ color: ev.color }}>{ev.title}</div>
                  </div>
                  <div className="text-sm font-bold text-[#191F28]">{ev.desc}</div>
                </div>
              </div>
            ))}
          </div>
        </div>
        {/* 하단 네비게이션 */}
        <nav className="absolute bottom-0 left-0 w-full bg-white border-t border-[#E5E8EB] flex justify-between items-center px-6 py-2 z-10 rounded-b-[24px]">
          <button className="flex flex-col items-center text-[#fa2e55] text-xs font-bold" onClick={() => setCurrentScreen && setCurrentScreen('calendar')}>
            <span className="material-icons text-[22px] mb-1">calendar_month</span>
            캘린더
          </button>
          <button className="flex flex-col items-center text-[#8B95A1] text-xs font-medium" onClick={() => setCurrentScreen && setCurrentScreen('timetable')}>
            <span className="material-icons text-[22px] mb-1">schedule</span>
            시간표
          </button>
          <button className="flex flex-col items-center text-[#8B95A1] text-xs font-medium" onClick={() => setCurrentScreen && setCurrentScreen('main')}>
            <span className="material-icons text-[22px] mb-1">home</span>
            홈
          </button>
          <button className="flex flex-col items-center text-[#8B95A1] text-xs font-medium" onClick={() => setCurrentScreen && setCurrentScreen('chat')}>
            <span className="material-icons text-[22px] mb-1">chat_bubble</span>
            채팅
          </button>
          <button className="flex flex-col items-center text-[#8B95A1] text-xs font-medium" onClick={() => setCurrentScreen && setCurrentScreen('settings')}>
            <span className="material-icons text-[22px] mb-1">settings</span>
            설정
          </button>
        </nav>
      </div>
    </div>
  );
} 