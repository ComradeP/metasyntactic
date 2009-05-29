// Copyright 2008 Cyrus Najmabadi
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#import "ArticlesOfConfederation.h"

#import "Article.h"
#import "Constitution.h"
#import "Person.h"
#import "Section.h"

@implementation ArticlesOfConfederation

static Constitution* articlesOfConfederation;

+ (void) setupArticlesOfConfederation {
  NSString* country = [[NSLocale currentLocale] displayNameForKey:NSLocaleCountryCode value:@"US"];
  
  NSString* preamble =
  NSLocalizedString(@"To all to whom these Presents shall come, we the undersigned Delegates of the States affixed to our Names send greeting.\n\n"
                    @"Articles of Confederation and perpetual Union between the States of New Hampshire, Massachusetts bay, Rhode Island and Providence Plantations, Connecticut, New York, New Jersey, Pennsylvania, Delaware, Maryland, Virginia, North Carolina, South Carolina and Georgia.", nil);
  
  NSArray* articles =
  [NSArray arrayWithObjects:
   [Article articleWithTitle:@"Article I"
                     section:[Section sectionWithText:NSLocalizedString(@"The Stile of this Confederacy shall be 'The United States of America.'", nil)]],
   [Article articleWithTitle:@"Article II"
                     section:[Section sectionWithText:NSLocalizedString(@"Each state retains its sovereignty, freedom, and independence, and every power, jurisdiction, and right, which is not by this Confederation expressly delegated to the United States, in Congress assembled.", nil)]],
   [Article articleWithTitle:@"Article III"
                     section:[Section sectionWithText:NSLocalizedString(@"The said States hereby severally enter into a firm league of friendship with each other, for their common defense, the security of their liberties, and their mutual and general welfare, binding themselves to assist each other, against all force offered to, or attacks made upon them, or any of them, on account of religion, sovereignty, trade, or any other pretense whatever.", nil)]],
   [Article articleWithTitle:@"Article IV"
                     section:[Section sectionWithText:NSLocalizedString(@"The better to secure and perpetuate mutual friendship and intercourse among the people of the different States in this Union, the free inhabitants of each of these States, paupers, vagabonds, and fugitives from justice excepted, shall be entitled to all privileges and immunities of free citizens in the several States; and the people of each State shall free ingress and regress to and from any other State, and shall enjoy therein all the privileges of trade and commerce, subject to the same duties, impositions, and restrictions as the inhabitants thereof respectively, provided that such restrictions shall not extend so far as to prevent the removal of property imported into any State, to any other State, of which the owner is an inhabitant; provided also that no imposition, duties or restriction shall be laid by any State, on the property of the United States, or either of them.\n\n"
                                                                        @"If any person guilty of, or charged with, treason, felony, or other high misdemeanor in any State, shall flee from justice, and be found in any of the United States, he shall, upon demand of the Governor or executive power of the State from which he fled, be delivered up and removed to the State having jurisdiction of his offense.\n\n"
                                                                        @"Full faith and credit shall be given in each of these States to the records, acts, and judicial proceedings of the courts and magistrates of every other State.", nil)]],
   [Article articleWithTitle:@"Article V"
                     section:[Section sectionWithText:NSLocalizedString(@"For the most convenient management of the general interests of the United States, delegates shall be annually appointed in such manner as the legislatures of each State shall direct, to meet in Congress on the first Monday in November, in every year, with a power reserved to each State to recall its delegates, or any of them, at any time within the year, and to send others in their stead for the remainder of the year.\n\n"
                                                                        @"No State shall be represented in Congress by less than two, nor more than seven members; and no person shall be capable of being a delegate for more than three years in any term of six years; nor shall any person, being a delegate, be capable of holding any office under the United States, for which he, or another for his benefit, receives any salary, fees or emolument of any kind.\n\n"
                                                                        @"Each State shall maintain its own delegates in a meeting of the States, and while they act as members of the committee of the States.\n\n"
                                                                        @"In determining questions in the United States in Congress assembled, each State shall have one vote.\n\n"
                                                                        @"Freedom of speech and debate in Congress shall not be impeached or questioned in any court or place out of Congress, and the members of Congress shall be protected in their persons from arrests or imprisonments, during the time of their going to and from, and attendance on Congress, except for treason, felony, or breach of the peace.", nil)]],
   [Article articleWithTitle:@"Article VI"
                     section:[Section sectionWithText:NSLocalizedString(@"No State, without the consent of the United States in Congress assembled, shall send any embassy to, or receive any embassy from, or enter into any conference, agreement, alliance or treaty with any King, Prince or State; nor shall any person holding any office of profit or trust under the United States, or any of them, accept any present, emolument, office or title of any kind whatever from any King, Prince or foreign State; nor shall the United States in Congress assembled, or any of them, grant any title of nobility.\n\n"
                                                                        @"No two or more States shall enter into any treaty, confederation or alliance whatever between them, without the consent of the United States in Congress assembled, specifying accurately the purposes for which the same is to be entered into, and how long it shall continue.\n\n"
                                                                        @"No State shall lay any imposts or duties, which may interfere with any stipulations in treaties, entered into by the United States in Congress assembled, with any King, Prince or State, in pursuance of any treaties already proposed by Congress, to the courts of France and Spain.\n\n"
                                                                        @"No vessel of war shall be kept up in time of peace by any State, except such number only, as shall be deemed necessary by the United States in Congress assembled, for the defense of such State, or its trade; nor shall any body of forces be kept up by any State in time of peace, except such number only, as in the judgement of the United States in Congress assembled, shall be deemed requisite to garrison the forts necessary for the defense of such State; but every State shall always keep up a well-regulated and disciplined militia, sufficiently armed and accoutered, and shall provide and constantly have ready for use, in public stores, a due number of filed pieces and tents, and a proper quantity of arms, ammunition and camp equipage.\n\n"
                                                                        @"No State shall engage in any war without the consent of the United States in Congress assembled, unless such State be actually invaded by enemies, or shall have received certain advice of a resolution being formed by some nation of Indians to invade such State, and the danger is so imminent as not to admit of a delay till the United States in Congress assembled can be consulted; nor shall any State grant commissions to any ships or vessels of war, nor letters of marque or reprisal, except it be after a declaration of war by the United States in Congress assembled, and then only against the Kingdom or State and the subjects thereof, against which war has been so declared, and under such regulations as shall be established by the United States in Congress assembled, unless such State be infested by pirates, in which case vessels of war may be fitted out for that occasion, and kept so long as the danger shall continue, or until the United States in Congress assembled shall determine otherwise.", nil)]],
   [Article articleWithTitle:@"Article VII"
                     section:[Section sectionWithText:NSLocalizedString(@"When land forces are raised by any State for the common defense, all officers of or under the rank of colonel, shall be appointed by the legislature of each State respectively, by whom such forces shall be raised, or in such manner as such State shall direct, and all vacancies shall be filled up by the State which first made the appointment.", nil)]],
   
   [Article articleWithTitle:@"Article VIII"
                     section:[Section sectionWithText:NSLocalizedString(@"All charges of war, and all other expenses that shall be incurred for the common defense or general welfare, and allowed by the United States in Congress assembled, shall be defrayed out of a common treasury, which shall be supplied by the several States in proportion to the value of all land within each State, granted or surveyed for any person, as such land and the buildings and improvements thereon shall be estimated according to such mode as the United States in Congress assembled, shall from time to time direct and appoint.\n\n"
                                                                        @"The taxes for paying that proportion shall be laid and levied by the authority and direction of the legislatures of the several States within the time agreed upon by the United States in Congress assembled.", nil)]],
   [Article articleWithTitle:@"Article IX"
                     section:[Section sectionWithText:NSLocalizedString(@"The United States in Congress assembled, shall have the sole and exclusive right and power of determining on peace and war, except in the cases mentioned in the sixth article — of sending and receiving ambassadors — entering into treaties and alliances, provided that no treaty of commerce shall be made whereby the legislative power of the respective States shall be restrained from imposing such imposts and duties on foreigners, as their own people are subjected to, or from prohibiting the exportation or importation of any species of goods or commodities whatsoever — of establishing rules for deciding in all cases, what captures on land or water shall be legal, and in what manner prizes taken by land or naval forces in the service of the United States shall be divided or appropriated — of granting letters of marque and reprisal in times of peace — appointing courts for the trial of piracies and felonies committed on the high seas and establishing courts for receiving and determining finally appeals in all cases of captures, provided that no member of Congress shall be appointed a judge of any of the said courts.\n\n"
                                                                        @"The United States in Congress assembled shall also be the last resort on appeal in all disputes and differences now subsisting or that hereafter may arise between two or more States concerning boundary, jurisdiction or any other causes whatever; which authority shall always be exercised in the manner following. Whenever the legislative or executive authority or lawful agent of any State in controversy with another shall present a petition to Congress stating the matter in question and praying for a hearing, notice thereof shall be given by order of Congress to the legislative or executive authority of the other State in controversy, and a day assigned for the appearance of the parties by their lawful agents, who shall then be directed to appoint by joint consent, commissioners or judges to constitute a court for hearing and determining the matter in question: but if they cannot agree, Congress shall name three persons out of each of the United States, and from the list of such persons each party shall alternately strike out one, the petitioners beginning, until the number shall be reduced to thirteen; and from that number not less than seven, nor more than nine names as Congress shall direct, shall in the presence of Congress be drawn out by lot, and the persons whose names shall be so drawn or any five of them, shall be commissioners or judges, to hear and finally determine the controversy, so always as a major part of the judges who shall hear the cause shall agree in the determination: and if either party shall neglect to attend at the day appointed, without showing reasons, which Congress shall judge sufficient, or being present shall refuse to strike, the Congress shall proceed to nominate three persons out of each State, and the secretary of Congress shall strike in behalf of such party absent or refusing; and the judgement and sentence of the court to be appointed, in the manner before prescribed, shall be final and conclusive; and if any of the parties shall refuse to submit to the authority of such court, or to appear or defend their claim or cause, the court shall nevertheless proceed to pronounce sentence, or judgement, which shall in like manner be final and decisive, the judgement or sentence and other proceedings being in either case transmitted to Congress, and lodged among the acts of Congress for the security of the parties concerned: provided that every commissioner, before he sits in judgement, shall take an oath to be administered by one of the judges of the supreme or superior court of the State, where the cause shall be tried, 'well and truly to hear and determine the matter in question, according to the best of his judgement, without favor, affection or hope of reward': provided also, that no State shall be deprived of territory for the benefit of the United States.\n\n"
                                                                        @"All controversies concerning the private right of soil claimed under different grants of two or more States, whose jurisdictions as they may respect such lands, and the States which passed such grants are adjusted, the said grants or either of them being at the same time claimed to have originated antecedent to such settlement of jurisdiction, shall on the petition of either party to the Congress of the United States, be finally determined as near as may be in the same manner as is before prescribed for deciding disputes respecting territorial jurisdiction between different States.\n\n"
                                                                        @"The United States in Congress assembled shall also have the sole and exclusive right and power of regulating the alloy and value of coin struck by their own authority, or by that of the respective States — fixing the standards of weights and measures throughout the United States — regulating the trade and managing all affairs with the Indians, not members of any of the States, provided that the legislative right of any State within its own limits be not infringed or violated — establishing or regulating post offices from one State to another, throughout all the United States, and exacting such postage on the papers passing through the same as may be requisite to defray the expenses of the said office — appointing all officers of the land forces, in the service of the United States, excepting regimental officers — appointing all the officers of the naval forces, and commissioning all officers whatever in the service of the United States — making rules for the government and regulation of the said land and naval forces, and directing their operations.\n\n"
                                                                        @"The United States in Congress assembled shall have authority to appoint a committee, to sit in the recess of Congress, to be denominated 'A Committee of the States', and to consist of one delegate from each State; and to appoint such other committees and civil officers as may be necessary for managing the general affairs of the United States under their direction — to appoint one of their members to preside, provided that no person be allowed to serve in the office of president more than one year in any term of three years; to ascertain the necessary sums of money to be raised for the service of the United States, and to appropriate and apply the same for defraying the public expenses — to borrow money, or emit bills on the credit of the United States, transmitting every half-year to the respective States an account of the sums of money so borrowed or emitted — to build and equip a navy — to agree upon the number of land forces, and to make requisitions from each State for its quota, in proportion to the number of white inhabitants in such State; which requisition shall be binding, and thereupon the legislature of each State shall appoint the regimental officers, raise the men and cloath, arm and equip them in a solid- like manner, at the expense of the United States; and the officers and men so cloathed, armed and equipped shall march to the place appointed, and within the time agreed on by the United States in Congress assembled. But if the United States in Congress assembled shall, on consideration of circumstances judge proper that any State should not raise men, or should raise a smaller number of men than the quota thereof, such extra number shall be raised, officered, cloathed, armed and equipped in the same manner as the quota of each State, unless the legislature of such State shall judge that such extra number cannot be safely spread out in the same, in which case they shall raise, officer, cloath, arm and equip as many of such extra number as they judge can be safely spared. And the officers and men so cloathed, armed, and equipped, shall march to the place appointed, and within the time agreed on by the United States in Congress assembled.\n\n"
                                                                        @"The United States in Congress assembled shall never engage in a war, nor grant letters of marque or reprisal in time of peace, nor enter into any treaties or alliances, nor coin money, nor regulate the value thereof, nor ascertain the sums and expenses necessary for the defense and welfare of the United States, or any of them, nor emit bills, nor borrow money on the credit of the United States, nor appropriate money, nor agree upon the number of vessels of war, to be built or purchased, or the number of land or sea forces to be raised, nor appoint a commander in chief of the army or navy, unless nine States assent to the same: nor shall a question on any other point, except for adjourning from day to day be determined, unless by the votes of the majority of the United States in Congress assembled.\n\n"
                                                                        @"The Congress of the United States shall have power to adjourn to any time within the year, and to any place within the United States, so that no period of adjournment be for a longer duration than the space of six months, and shall publish the journal of their proceedings monthly, except such parts thereof relating to treaties, alliances or military operations, as in their judgement require secrecy; and the yeas and nays of the delegates of each State on any question shall be entered on the journal, when it is desired by any delegates of a State, or any of them, at his or their request shall be furnished with a transcript of the said journal, except such parts as are above excepted, to lay before the legislatures of the several States.", nil)]],
   [Article articleWithTitle:@"Article X"
                     section:[Section sectionWithText:NSLocalizedString(@"The Committee of the States, or any nine of them, shall be authorized to execute, in the recess of Congress, such of the powers of Congress as the United States in Congress assembled, by the consent of the nine States, shall from time to time think expedient to vest them with; provided that no power be delegated to the said Committee, for the exercise of which, by the Articles of Confederation, the voice of nine States in the Congress of the United States assembled be requisite.", nil)]],
   [Article articleWithTitle:@"Article XI"
                     section:[Section sectionWithText:NSLocalizedString(@"Canada acceding to this confederation, and adjoining in the measures of the United States, shall be admitted into, and entitled to all the advantages of this Union; but no other colony shall be admitted into the same, unless such admission be agreed to by nine States.", nil)]],
   [Article articleWithTitle:@"Article XII"
                     section:[Section sectionWithText:NSLocalizedString(@"All bills of credit emitted, monies borrowed, and debts contracted by, or under the authority of Congress, before the assembling of the United States, in pursuance of the present confederation, shall be deemed and considered as a charge against the United States, for payment and satisfaction whereof the said United States, and the public faith are hereby solemnly pledged.", nil)]],
   [Article articleWithTitle:@"Article XIII"
                     section:[Section sectionWithText:NSLocalizedString(@"Every State shall abide by the determination of the United States in Congress assembled, on all questions which by this confederation are submitted to them. And the Articles of this Confederation shall be inviolably observed by every State, and the Union shall be perpetual; nor shall any alteration at any time hereafter be made in any of them; unless such alteration be agreed to in a Congress of the United States, and be afterwards confirmed by the legislatures of every State.", nil)]],
   
   nil];
  
  NSString* conclusion = @"And Whereas it hath pleased the Great Governor of the World to incline the hearts of the legislatures we respectively represent in Congress, to approve of, and to authorize us to ratify the said Articles of Confederation and perpetual Union. Know Ye that we the undersigned delegates, by virtue of the power and authority to us given for that purpose, do by these presents, in the name and in behalf of our respective constituents, fully and entirely ratify and confirm each and every of the said Articles of Confederation and perpetual Union, and all and singular the matters and things therein contained: And we do further solemnly plight and engage the faith of our respective constituents, that they shall abide by the determinations of the United States in Congress assembled, on all questions, which by the said Confederation are submitted to them. And that the Articles thereof shall be inviolably observed by the States we respectively represent, and that the Union shall be perpetual.";
  
  MutableMultiDictionary* signers = [MutableMultiDictionary dictionary];
  [signers addObjects:[NSArray arrayWithObjects:
                       person(@"Josiah Bartlett", @"http://en.wikipedia.org/wiki/Josiah_Bartlett"),
                       person(@"John Wentworth Jr.", @"http://en.wikipedia.org/wiki/John_Wentworth_Jr."),nil]
               forKey:@"New Hampshire"];
  
  [signers addObjects:[NSArray arrayWithObjects:
                       person(@"John Hancock", @"http://en.wikipedia.org/wiki/John_Hancock"),
                       person(@"Samuel Adams", @"http://en.wikipedia.org/wiki/Samuel_Adams"),
                       person(@"Elbridge Gerry", @"http://en.wikipedia.org/wiki/Elbridge_Gerry"),
                       person(@"Francis Dana", @"http://en.wikipedia.org/wiki/Francis_Dana"),
                       person(@"James Lovell", @"http://en.wikipedia.org/wiki/James_Lovell_(delegate)"),
                       person(@"Samuel Holten", @"http://en.wikipedia.org/wiki/Samuel_Holten"),nil]
               forKey:@"Massachusetts"];
  
  [signers addObjects:[NSArray arrayWithObjects:
                       person(@"William Ellery", @"http://en.wikipedia.org/wiki/William_Ellery"),
                       person(@"Henry Marchant", @"http://en.wikipedia.org/wiki/Henry_Marchant"),
                       person(@"John Collins", @"http://en.wikipedia.org/wiki/John_Collins_(delegate)"),nil]
               forKey:@"Rhode Island"];
  
  [signers addObjects:[NSArray arrayWithObjects:
                       person(@"Roger Sherman", @"http://en.wikipedia.org/wiki/Roger_Sherman"),
                       person(@"Samuel Huntington", @"http://en.wikipedia.org/wiki/Samuel_Huntington_(statesman)"),
                       person(@"Oliver Wolcott", @"http://en.wikipedia.org/wiki/Oliver_Wolcott"),
                       person(@"Titus Hosmer", @"http://en.wikipedia.org/wiki/Titus_Hosmer"),
                       person(@"Andrew Adams", @"http://en.wikipedia.org/wiki/Andrew_Adams_(congressman)"),nil]
               forKey:@"Connecticut"];
  
  [signers addObjects:[NSArray arrayWithObjects:
                       person(@"James Duane", @"http://en.wikipedia.org/wiki/James_Duane"),
                       person(@"Francis Lewis", @"http://en.wikipedia.org/wiki/Francis_Lewis"),
                       person(@"William Duer", @"http://en.wikipedia.org/wiki/William_Duer_(1747-1799)"),
                       person(@"Gouverneur Morris", @"http://en.wikipedia.org/wiki/Gouverneur_Morris"),nil]
               forKey:@"New York"];
  
  [signers addObjects:[NSArray arrayWithObjects:
                       person(@"John Witherspoon", @"http://en.wikipedia.org/wiki/John_Witherspoon"),
                       person(@"Nathaniel Scudder", @"http://en.wikipedia.org/wiki/Nathaniel_Scudder"),nil]
               forKey:@"New Jersey"];
  
  [signers addObjects:[NSArray arrayWithObjects:
                       person(@"Robert Morris", @"http://en.wikipedia.org/wiki/Robert_Morris_(financier)"),
                       person(@"Daniel Roberdeau", @"http://en.wikipedia.org/wiki/Daniel_Roberdeau"),
                       person(@"John Bayard Smith", @"http://en.wikipedia.org/wiki/Jonathan_Bayard_Smith"),
                       person(@"William Clingan", @"http://en.wikipedia.org/wiki/William_Clingan"),
                       person(@"Joseph Reed", @"http://en.wikipedia.org/wiki/Joseph_Reed_(jurist)"),nil]
               forKey:@"Pennsylvania"];
  
  [signers addObjects:[NSArray arrayWithObjects:
                       person(@"Thomas Mckean", @"http://en.wikipedia.org/wiki/Thomas_McKean"),
                       person(@"John Dickinson", @"http://en.wikipedia.org/wiki/John_Dickinson_(delegate)"),
                       person(@"Nicholas Van Dyke", @"http://en.wikipedia.org/wiki/Nicholas_Van_Dyke_(governor)"),nil]
               forKey:@"Deleware"];
  
  [signers addObjects:[NSArray arrayWithObjects:
                       person(@"John Hanson", @"http://en.wikipedia.org/wiki/John_Hanson"),
                       person(@"Daniel Carroll", @"http://en.wikipedia.org/wiki/Daniel_Carroll"),nil]
               forKey:@"Maryland"];
  
  [signers addObjects:[NSArray arrayWithObjects:
                       person(@"Richard Henry Lee", @"http://en.wikipedia.org/wiki/Richard_Henry_Lee"),
                       person(@"John Banister", @"http://en.wikipedia.org/wiki/John_Banister_(lawyer)"),
                       person(@"Thomas Adams", @"http://en.wikipedia.org/wiki/Thomas_Adams_(politician)"),
                       person(@"John Harvie", @"http://en.wikipedia.org/wiki/John_Harvie"),
                       person(@"Francis Lightfoot Lee", @"http://en.wikipedia.org/wiki/Francis_Lightfoot_Lee"),nil]
               forKey:@"Virginia"];
  
  [signers addObjects:[NSArray arrayWithObjects:
                       person(@"John Penn", @"http://en.wikipedia.org/wiki/John_Penn_(delegate)"),
                       person(@"Cornelius Harnett", @"http://www.google.com/url?q=http://en.wikipedia.org/wiki/Cornelius_Harnett&ei=NkioSYigCYH8tgfN7MHXDw&sa=X&oi=spellmeleon_result&resnum=1&ct=result&cd=1&usg=AFQjCNHDpzuq6d5jPavCHKx2E2VgIvpFGQ"),
                       person(@"John Williams", @"http://en.wikipedia.org/wiki/John_Williams_(delegate)"),nil]
               forKey:@"North Carolina"];
  
  [signers addObjects:[NSArray arrayWithObjects:
                       person(@"Henry Laurens", @"http://en.wikipedia.org/wiki/Henry_Laurens"),
                       person(@"William Henry Drayton", @"http://en.wikipedia.org/wiki/William_Henry_Drayton"),
                       person(@"Jno Mathews", @"http://en.wikipedia.org/wiki/John_Mathews"),
                       person(@"Richard Hutson", @"http://www.google.com/url?q=http://en.wikipedia.org/wiki/Richard_Hutson"),
                       person(@"Thomas Heyward Jr.", @"http://en.wikipedia.org/wiki/Thomas_Heyward,_Jr."),nil]
               forKey:@"South Carolina"];
  
  [signers addObjects:[NSArray arrayWithObjects:
                       person(@"George Walton", @"http://en.wikipedia.org/wiki/George_Walton"),
                       person(@"Edward Telfair", @"http://en.wikipedia.org/wiki/Edward_Telfair"),
                       person(@"Edward Langworthy", @"http://en.wikipedia.org/wiki/Edward_Langworthy"),nil]
               forKey:@"Georgia"];
  
  articlesOfConfederation =
  [[Constitution constitutionWithCountry:country
                                preamble:preamble
                                articles:articles
                              amendments:[NSArray array]
                              conclusion:conclusion
                                 signers:signers] retain];
}


+ (void) initialize {
  if (self == [ArticlesOfConfederation class]) {
    [self setupArticlesOfConfederation];
  }
}


+ (Constitution*) articlesOfConfederation {
  return articlesOfConfederation;
}

@end