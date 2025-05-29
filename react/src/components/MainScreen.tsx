import React, { useState } from "react";
import { BellIcon, PlusIcon } from "@heroicons/react/24/outline";
import TomatoProfile from './TomatoProfile';
import ChoreIcon from './ChoreIcon';
import ChoreDetailScreen from './ChoreDetailScreen';
import ReservationIcon from './ReservationIcon';
import VisitorReservationScreen from './VisitorReservationScreen';
import BathReservationScreen from './BathReservationScreen';
import LaundryReservationScreen from './LaundryReservationScreen';

type ScreenType = 'onboarding' | 'roomSelect' | 'roomCreate' | 'loading' | 'main' | 'timetable' | 'calendar' | 'chat' | 'settings' | 'notification';

// 쪽지 타입
interface NoteType {
  id: number;
  from: string;
  to: string;
  message: string;
}

export default function MainScreen({ setCurrentScreen }: { setCurrentScreen: (screen: ScreenType) => void }) {
  const [selectedChore, setSelectedChore] = useState<string | null>(null);
  const [selectedTab, setSelectedTab] = useState<'집안일' | '예약'>('집안일');
  const [visitorReservation, setVisitorReservation] = useState(false);
  const [bathReservation, setBathReservation] = useState(false);
  const [laundryReservation, setLaundryReservation] = useState(false);
  const [selectedProfile, setSelectedProfile] = useState<number | null>(null);
  const [showNoteModal, setShowNoteModal] = useState(false);
  const [noteTarget, setNoteTarget] = useState<number | null>(null);
  const [receivedNotes, setReceivedNotes] = useState<NoteType[]>([]);
  const [showMailbox, setShowMailbox] = useState(false);
  const [noteInput, setNoteInput] = useState('');
  const [noteMode, setNoteMode] = useState<'preset' | 'custom'>('preset');
  const presetPhrases = ['조용히 해줘', '고마워', '미안해', '직접입력'];
  // 예시 데이터
  const members = [
    { name: "김민영", role: "방장", active: true },
    { name: "최현경", role: "", active: false },
    { name: "민수연", role: "", active: false },
    { name: "홍수한", role: "", active: false },
  ];
  const todos = [
    "화장실 청소하기",
    "쓰레기 분리수거",
    "화장지 사기",
  ];

  // 집안일 카드 데이터
  const choreCards = [
    { label: '청소', icon: <ChoreIcon type="clean" />, onClick: () => setSelectedChore('청소') },
    { label: '분리수거', icon: <ChoreIcon type="trash" />, onClick: () => setSelectedChore('분리수거') },
    { label: '설거지', icon: <ChoreIcon type="dish" />, onClick: () => setSelectedChore('설거지') },
    { label: '추가', icon: <span className="text-2xl mb-1 text-[#fa2e55]">＋</span>, isAdd: true },
  ];
  // 예약 카드 데이터 (이모지 아이콘 우선)
  const reservationCards = [
    { label: '욕실', icon: <ReservationIcon type="bath" />, onClick: () => setBathReservation(true) },
    { label: '세탁기', icon: <ReservationIcon type="laundry" />, onClick: () => setLaundryReservation(true) },
    { label: '방문객', icon: <ReservationIcon type="visitor" />, onClick: () => setVisitorReservation(true) },
    { label: '추가', icon: <ReservationIcon type="add" />, isAdd: true },
  ];

  const [showAddChoreModal, setShowAddChoreModal] = useState(false);
  const [showAddReservationModal, setShowAddReservationModal] = useState(false);
  const [newChoreName, setNewChoreName] = useState('');
  const [newReservationName, setNewReservationName] = useState('');
  const [choreCardsState, setChoreCardsState] = useState(choreCards);
  const [reservationCardsState, setReservationCardsState] = useState(reservationCards);

  const [showInviteModal, setShowInviteModal] = useState(false);
  const inviteCode = 'ABCD1234'; // 예시, 실제로는 이전에 만든 코드 생성 로직 사용

  // 쪽지 보내기
  const handleSendNote = (msg: string) => {
    if (noteTarget !== null) {
      setReceivedNotes(notes => [...notes, { id: Date.now(), from: '나', to: members[noteTarget].name, message: msg }]);
    }
    setShowNoteModal(false);
    setNoteInput('');
    setNoteMode('preset');
    setSelectedProfile(null);
  };

  // 집안일 추가
  const handleAddChore = () => {
    if (!newChoreName.trim()) return;
    setChoreCardsState([
      ...choreCardsState.slice(0, -1),
      { label: newChoreName, icon: <ChoreIcon type="clean" />, onClick: () => setSelectedChore(newChoreName) },
      choreCardsState[choreCardsState.length - 1],
    ]);
    setShowAddChoreModal(false);
    setNewChoreName('');
  };
  // 예약 추가
  const handleAddReservation = () => {
    if (!newReservationName.trim()) return;
    setReservationCardsState([
      ...reservationCardsState.slice(0, -1),
      { label: newReservationName, icon: <ReservationIcon type="add" />, onClick: () => {} },
      reservationCardsState[reservationCardsState.length - 1],
    ]);
    setShowAddReservationModal(false);
    setNewReservationName('');
  };

  if (selectedChore) {
    return (
      <ChoreDetailScreen
        choreType={selectedChore}
        onBack={() => setSelectedChore(null)}
        onDeleteChore={(choreType) => {
          setChoreCardsState(cards => cards.filter(card => card.label !== choreType));
          setSelectedChore(null);
        }}
      />
    );
  }
  if (visitorReservation) {
    return <VisitorReservationScreen onBack={() => setVisitorReservation(false)} />;
  }
  if (bathReservation) {
    return <BathReservationScreen onBack={() => setBathReservation(false)} />;
  }
  if (laundryReservation) {
    return <LaundryReservationScreen onBack={() => setLaundryReservation(false)} />;
  }
  return (
    <div className="w-full min-h-screen flex items-center justify-center bg-[#F9FAFB] font-toss">
      <div className="bg-white w-full max-w-[390px] min-h-[844px] max-h-[844px] h-[844px] relative flex flex-col mx-auto shadow-2xl rounded-[24px] overflow-hidden">
        {/* 상단 헤더 */}
        <header className="flex items-center justify-between px-6 pt-8 pb-4">
          <div className="flex flex-col items-center w-full">
            <div className="relative flex flex-col items-center">
              {/* 문패 고리 */}
              <div className="w-8 h-2 bg-[#E5E8EB] rounded-b-full mb-[-6px] z-10" />
              {/* 문패 본체 */}
              <div className="bg-white border-2 border-[#FA2E55] rounded-xl px-6 py-2 shadow-sm text-[#191F28] font-bold text-lg tracking-tight flex items-center gap-2">
                방토리네 302호
              </div>
            </div>
          </div>
          <div className="relative">
            <button type="button" onClick={() => setCurrentScreen('notification')} className="relative">
              <BellIcon className="h-6 w-6 text-[#191F28]" />
              <div className="absolute w-2 h-2 top-0 right-0 bg-[#fa2e55] rounded-full" />
            </button>
          </div>
        </header>

        {/* 멤버 리스트 */}
        <section className="flex items-center gap-4 px-6 py-2 bg-[#F9FAFB] rounded-xl mx-4 mb-4 relative">
          {members.map((m, i) => (
            <div key={i} className="flex flex-col items-center">
              <TomatoProfile size={44} active={m.active} index={i} onClick={() => { setSelectedProfile(i); setNoteTarget(i); setShowNoteModal(true); }} style={selectedProfile === i ? { border: '2px solid #FA2E55', boxShadow: '0 0 0 4px #FA2E5522' } : {}} />
              <span className={`text-xs mt-1 ${m.active ? "text-[#fa2e55] font-bold" : "text-[#8B95A1]"}`}>{m.name}</span>
              {m.role && <span className="text-[10px] text-[#8B95A1]">{m.role}</span>}
            </div>
          ))}
          {/* 초대 + 버튼 */}
          <button className="flex flex-col items-center justify-center w-11 h-11 rounded-full border-2 border-dashed border-[#FA2E55] text-[#FA2E55] text-2xl font-bold ml-2 hover:bg-[#FFF0F4] transition" onClick={() => setShowInviteModal(true)}>
            <span>＋</span>
          </button>
          {/* 우체통 */}
          {receivedNotes.length > 0 && (
            <button className="absolute right-0 top-0 flex flex-col items-center animate-bounce" onClick={() => setShowMailbox(true)}>
              <span className="material-icons text-3xl text-[#FA2E55]">mail</span>
              <span className="text-xs text-[#FA2E55] font-bold">{receivedNotes.length}</span>
            </button>
          )}
        </section>

        {/* 집안일/예약 탭 */}
        <section className="px-6">
          <div className="flex border-b border-[#E5E8EB] mb-2">
            <button className={`flex-1 py-2 text-center font-bold border-b-2 bg-transparent transition-colors ${selectedTab === '집안일' ? 'text-[#fa2e55] border-[#fa2e55]' : 'text-[#8B95A1] border-transparent'}`} onClick={() => setSelectedTab('집안일')}>집안일</button>
            <button className={`flex-1 py-2 text-center font-bold border-b-2 bg-transparent transition-colors ${selectedTab === '예약' ? 'text-[#fa2e55] border-[#fa2e55]' : 'text-[#8B95A1] border-transparent'}`} onClick={() => setSelectedTab('예약')}>예약</button>
          </div>
          {/* 카드 영역 - 4개 이하: 2x2 grid로 꽉 채움, 5개 이상: 2줄 flex-row 좌우 스크롤 */}
          {(() => {
            const cards = selectedTab === '집안일' ? choreCardsState : reservationCardsState;
            if (cards.length <= 4) {
              return (
                <div className="bg-[#F9FAFB] rounded-xl border border-[#F2F4F6] px-3 py-4 mb-4">
                  <div className="grid grid-cols-2 grid-rows-2 gap-2 w-full h-[256px]">
                    {cards.map((card, idx) => (
                      <button
                        key={idx}
                        className="bg-white border border-[#E5E8EB] rounded-2xl flex flex-col items-center justify-center w-full h-full shadow-sm hover:border-[#fa2e55] transition"
                        onClick={('isAdd' in card && card.isAdd) ? (selectedTab === '집안일' ? () => setShowAddChoreModal(true) : () => setShowAddReservationModal(true)) : (card.onClick as () => void)}
                      >
                        <div className="text-3xl mb-2">{card.icon}</div>
                        <span className="text-sm text-[#191F28] font-medium text-center break-keep leading-tight">{card.label}</span>
                      </button>
                    ))}
                  </div>
                </div>
              );
            }
            // 5개 이상: 2줄 flex-row 좌우 스크롤
            // 2개씩 묶기
            const chunked: (typeof cards[number] | undefined)[][] = [];
            for (let i = 0; i < cards.length; i += 2) {
              const pair: (typeof cards[number] | undefined)[] = cards.slice(i, i + 2);
              if (pair.length < 2) pair.push(undefined);
              chunked.push(pair);
            }
            return (
              <div className="overflow-x-auto scrollbar-hide bg-[#F9FAFB] rounded-xl border border-[#F2F4F6] px-3 py-4 mb-4">
                <div className="flex flex-row gap-2">
                  {chunked.map((pair, colIdx) => (
                    <div key={colIdx} className="flex flex-col gap-2 min-w-[112px] max-w-[140px]">
                      {pair.map((card, rowIdx) => (
                        card ? (
                          <button
                            key={rowIdx}
                            className="bg-white border border-[#E5E8EB] rounded-2xl flex flex-col items-center justify-center min-w-[112px] max-w-[140px] aspect-square shadow-sm hover:border-[#fa2e55] transition"
                            onClick={('isAdd' in card && card.isAdd) ? (selectedTab === '집안일' ? () => setShowAddChoreModal(true) : () => setShowAddReservationModal(true)) : (card.onClick as () => void)}
                          >
                            <div className="text-3xl mb-2">{card.icon}</div>
                            <span className="text-sm text-[#191F28] font-medium text-center break-keep leading-tight">{card.label}</span>
                          </button>
                        ) : (
                          <div key={rowIdx} className="invisible min-w-[112px] max-w-[140px] aspect-square" />
                        )
                      ))}
                    </div>
                  ))}
                </div>
              </div>
            );
          })()}
        </section>

        {/* 나의 할 일 */}
        <section className="px-6 mb-4">
          <div className="bg-[#F9FAFB] rounded-2xl shadow-none p-4 border border-[#F2F4F6]">
            <div className="flex justify-between items-center mb-4">
              <h3 className="font-bold text-base text-[#191F28]">나의 할 일</h3>
              <button className="h-7 px-3 text-xs rounded-full bg-[#FA2E55] text-white font-bold flex items-center gap-1 shadow-none hover:bg-[#e0264a] active:scale-95 transition-all">
                확인하기
                <span className="material-icons text-base">chevron_right</span>
              </button>
            </div>
            <div className="space-y-2">
              {todos.map((t, i) => (
                <div key={i} className="flex items-center gap-3 p-3 rounded-xl bg-white border border-[#F2F4F6]">
                  <input type="checkbox" className="w-5 h-5 accent-[#FA2E55] rounded-full border-2 border-[#FA2E55] focus:ring-0" />
                  <label className="text-sm text-[#191F28] cursor-pointer select-none">{t}</label>
                </div>
              ))}
            </div>
          </div>
        </section>

        {/* 오늘 일정 */}
        <section className="px-6 mb-4">
          <div className="bg-[#F9FAFB] rounded-2xl shadow-none p-4 min-h-[80px] flex flex-col justify-center items-center border border-[#F2F4F6]">
            <h3 className="font-bold text-base text-[#191F28] mb-2">오늘 일정</h3>
            <p className="text-sm text-[#8B95A1]">등록된 일정이 없습니다</p>
          </div>
        </section>

        {/* 쪽지 보내기 모달 */}
        {showNoteModal && noteTarget !== null && (
          <div className="absolute inset-0 flex items-center justify-center bg-black/20 z-30">
            <div className="bg-white rounded-2xl p-6 w-80 max-w-[90vw] flex flex-col items-center shadow-xl">
              <div className="text-lg font-bold text-[#191F28] mb-4">쪽지 입력</div>
              <div className="flex flex-col gap-2 w-full mb-4">
                {noteMode === 'preset' ? (
                  <div className="grid grid-cols-2 gap-2">
                    {presetPhrases.map((p, idx) => (
                      <button key={idx} className="h-10 rounded-xl border border-[#FA2E55] bg-[#FFF0F4] text-[#FA2E55] font-bold" onClick={() => {
                        if (p === '직접입력') setNoteMode('custom');
                        else handleSendNote(p);
                      }}>{p}</button>
                    ))}
                  </div>
                ) : (
                  <textarea className="w-full h-24 rounded-xl border-2 border-[#FA2E55] p-3 text-sm mb-2" placeholder="메시지를 입력하세요." value={noteInput} onChange={e => setNoteInput(e.target.value)} />
                )}
              </div>
              {noteMode === 'custom' && (
                <div className="flex gap-2 w-full">
                  <button className="flex-1 h-10 rounded-xl border border-[#E5E8EB] bg-white text-[#191F28] text-sm font-bold" onClick={() => { setNoteMode('preset'); setNoteInput(''); }}>취소</button>
                  <button className="flex-1 h-10 rounded-xl bg-[#FA2E55] text-white text-sm font-bold" onClick={() => { if(noteInput.trim()) handleSendNote(noteInput); }}>보내기</button>
                </div>
              )}
              {noteMode === 'preset' && (
                <button className="mt-2 text-xs text-[#8B95A1] underline" onClick={() => setShowNoteModal(false)}>닫기</button>
              )}
            </div>
          </div>
        )}
        {/* 우체통 모달 */}
        {showMailbox && (
          <div className="absolute inset-0 flex items-center justify-center bg-black/20 z-30">
            <div className="bg-white rounded-2xl p-6 w-80 max-w-[90vw] flex flex-col items-center shadow-xl">
              <div className="text-lg font-bold text-[#FA2E55] mb-4">받은 쪽지</div>
              <div className="flex flex-col gap-3 w-full mb-4">
                {receivedNotes.map(note => (
                  <div key={note.id} className="bg-[#FFF0F4] border border-[#FA2E55] rounded-xl p-4 flex flex-col items-start relative">
                    <button className="absolute top-2 right-2 text-[#FA2E55]" onClick={() => setReceivedNotes(notes => notes.filter(n => n.id !== note.id))}>
                      <span className="material-icons text-base">close</span>
                    </button>
                    <div className="text-base font-bold text-[#191F28] mb-2">{note.message}</div>
                    <div className="text-xs text-[#8B95A1] mb-2">by. {note.from}</div>
                    <button className="self-end h-8 px-4 rounded-full bg-[#FA2E55] text-white text-xs font-bold active:scale-95 transition" onClick={() => setReceivedNotes(notes => notes.filter(n => n.id !== note.id))}>확인</button>
                  </div>
                ))}
                {receivedNotes.length === 0 && <div className="text-sm text-[#8B95A1] text-center py-8">받은 쪽지가 없습니다</div>}
              </div>
              <button className="w-full h-10 rounded-xl border border-[#E5E8EB] bg-white text-[#191F28] text-sm font-bold" onClick={() => setShowMailbox(false)}>닫기</button>
            </div>
          </div>
        )}

        {/* 집안일 카테고리 추가 모달 */}
        {showAddChoreModal && (
          <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/20">
            <div className="bg-white rounded-2xl p-6 w-80 max-w-[90vw] flex flex-col items-center shadow-xl animate-fade-in">
              <div className="text-lg font-bold text-[#191F28] mb-4">집안일 카테고리 추가</div>
              <div className="w-16 h-16 rounded-full bg-[#F2F4F6] mb-4" />
              <input
                className="w-full h-12 rounded-xl border-2 border-[#FA2E55] px-4 text-base mb-6 focus:outline-none focus:ring-2 focus:ring-[#FA2E55]"
                placeholder="집안일 주제 이름"
                value={newChoreName}
                onChange={e => setNewChoreName(e.target.value)}
              />
              <div className="flex w-full gap-2">
                <button className="flex-1 h-11 rounded-xl bg-[#F2F4F6] text-[#191F28] text-base font-bold" onClick={() => { setShowAddChoreModal(false); setNewChoreName(''); }}>취소</button>
                <button className="flex-1 h-11 rounded-xl bg-[#FA2E55] text-white text-base font-bold" onClick={handleAddChore}>등록하기</button>
              </div>
            </div>
          </div>
        )}
        {/* 예약 카테고리 추가 모달 */}
        {showAddReservationModal && (
          <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/20">
            <div className="bg-white rounded-2xl p-6 w-80 max-w-[90vw] flex flex-col items-center shadow-xl animate-fade-in">
              <div className="text-lg font-bold text-[#191F28] mb-4">예약 카테고리 추가</div>
              <div className="w-16 h-16 rounded-full bg-[#F2F4F6] mb-4" />
              <input
                className="w-full h-12 rounded-xl border-2 border-[#FA2E55] px-4 text-base mb-6 focus:outline-none focus:ring-2 focus:ring-[#FA2E55]"
                placeholder="예약 주제 이름"
                value={newReservationName}
                onChange={e => setNewReservationName(e.target.value)}
              />
              <div className="flex w-full gap-2">
                <button className="flex-1 h-11 rounded-xl bg-[#F2F4F6] text-[#191F28] text-base font-bold" onClick={() => { setShowAddReservationModal(false); setNewReservationName(''); }}>취소</button>
                <button className="flex-1 h-11 rounded-xl bg-[#FA2E55] text-white text-base font-bold" onClick={handleAddReservation}>등록하기</button>
              </div>
            </div>
          </div>
        )}

        {/* 초대코드 모달 */}
        {showInviteModal && (
          <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/20">
            <div className="bg-white rounded-2xl p-6 w-80 max-w-[90vw] flex flex-col items-center shadow-xl animate-fade-in">
              <div className="text-lg font-bold text-[#191F28] mb-4">초대 코드</div>
              <div className="text-2xl font-mono text-[#FA2E55] bg-[#F2F4F6] rounded-xl px-6 py-4 mb-4 tracking-widest select-all">{inviteCode}</div>
              <div className="text-xs text-[#8B95A1] mb-6">이 코드를 복사해서 친구에게 보내주세요!</div>
              <button className="w-full h-11 rounded-xl bg-[#FA2E55] text-white text-base font-bold" onClick={() => setShowInviteModal(false)}>닫기</button>
            </div>
          </div>
        )}

        {/* 하단 네비게이션 */}
        <nav className="absolute bottom-0 left-0 w-full bg-white border-t border-[#E5E8EB] flex justify-between items-center px-6 py-2 z-10 rounded-b-[24px]">
          <button className="flex flex-col items-center text-[#8B95A1] text-xs font-medium" onClick={() => setCurrentScreen('calendar')}>
            <span className="material-icons text-[22px] mb-1">calendar_month</span>
            캘린더
          </button>
          <button className="flex flex-col items-center text-[#8B95A1] text-xs font-medium" onClick={() => setCurrentScreen('timetable')}>
            <span className="material-icons text-[22px] mb-1">schedule</span>
            시간표
          </button>
          <button className="flex flex-col items-center text-[#fa2e55] text-xs font-bold" onClick={() => setCurrentScreen('main')}>
            <span className="material-icons text-[22px] mb-1">home</span>
            홈
          </button>
          <button className="flex flex-col items-center text-[#8B95A1] text-xs font-medium" onClick={() => setCurrentScreen('chat')}>
            <span className="material-icons text-[22px] mb-1">chat_bubble</span>
            채팅
          </button>
          <button className="flex flex-col items-center text-[#8B95A1] text-xs font-medium" onClick={() => setCurrentScreen('settings')}>
            <span className="material-icons text-[22px] mb-1">settings</span>
            설정
          </button>
        </nav>
      </div>
    </div>
  );
} 