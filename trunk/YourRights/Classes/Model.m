//
//  Model.m
//  YourRights
//
//  Created by Cyrus Najmabadi on 1/5/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Model.h"


@implementation Model

static NSArray* sectionTitles;
static NSArray* shortSectionTitles;
static NSArray* questions;
static NSArray* answers;
static NSArray* preambles;
static NSArray* otherResources;
static NSArray* sectionLinks;
static NSArray* links;

+ (void) initialize {
    if (self == [Model class]) {
        sectionTitles = [[NSArray arrayWithObjects:
                          NSLocalizedString(@"Questioning", nil),
                          NSLocalizedString(@"Stops and Arrests", nil),
                          NSLocalizedString(@"Searches and Warrants", nil),
                          NSLocalizedString(@"Additional Information for Non-Citizens", nil),
                          NSLocalizedString(@"Rights at Airports and Other Ports of Entry into the United States", nil),
                          NSLocalizedString(@"Charitable Donations and Religious Practices", nil), nil] retain];
        
        shortSectionTitles = [[NSArray arrayWithObjects:
                               NSLocalizedString(@"Questioning", nil),
                               NSLocalizedString(@"Stops and Arrests", nil),
                               NSLocalizedString(@"Searches and Warrants", nil),
                               NSLocalizedString(@"Info for Non-Citizens", nil),
                               NSLocalizedString(@"Rights at Airports", nil),
                               NSLocalizedString(@"Charitable Donations", nil), nil] retain];
        
        
        preambles = [[NSArray arrayWithObjects:
                      @"",
                      @"",
                      @"",
                      NSLocalizedString(@"In the United States, non-citizens are persons who do not have U.S. " 
                                        @"citizenship, including lawful permanent residents, refugees and asylum "
                                        @"seekers, persons who have permission to come to the U.S. for reasons "
                                        @"like work, school or travel, and those without legal immigration status of "
                                        @"any kind. Non-citizens who are in the United States-no matter what "
                                        @"their immigration status-generally have the same constitutional rights "
                                        @"as citizens when law enforcement officers stop, question, arrest, or "
                                        @"search them or their homes. However, there are some special concerns "
                                        @"that apply to non-citizens, so the following rights and responsibilities are "
                                        @"important for non-citizens to know. Non-citizens at the border who are "
                                        @"trying to enter the U.S. do not have all the same rights. See Section 5 for "
                                        @"more information if you are arriving in the U.S.", nil),
                      NSLocalizedString(@"Remember: It is illegal for law enforcement officers to perform any stops, "
                                        @"searches, detentions or removals based solely on your race, national origin, "
                                        @"religion, sex or ethnicity. However, Customs and Border Protection officials "
                                        @"can stop you based on citizenship or travel itinerary at the border and search "
                                        @"all bags.", nil),
                      @"", nil] retain];
        
        otherResources = [[NSArray arrayWithObjects:
                           [NSArray array],
                           [NSArray array],
                           [NSArray array],
                           [NSArray array],
                           [NSArray arrayWithObjects:
                            NSLocalizedString(@"DHS Office for Civil Rights and Civil Liberties\n" 
                                              @"http://www.dhs.gov/xabout/structure/editorial_0373.shtm "
                                              @"Investigates abuses of civil rights, civil liberties, and profiling "
                                              @"on the basis of race, ethnicity, or religion by employees and "
                                              @"officials of the Department of Homeland Security. You can submit "
                                              @"your complaint via email to civil.liberties@dhs.gov.", nil),
                            NSLocalizedString(@"U.S. Department of Transportation's Aviation Consumer Protected Division\n"
                                              @"http://airconsumer.ost.dot.gov/problems.htm "
                                              @"Handles complaints against the airline for mistreatment by air "
                                              @"carrier personnel (check-in, gate staff, plane staff, pilot), "
                                              @"including discrimination on the basis of race, ethnicity, religion, "
                                              @"sex, national origin, ancestry, or disability. You can submit a "
                                              @"complaint via email to airconsumer@ost.dot.gov-see the webpage "
                                              @"page for what information to include.", nil),
                            NSLocalizedString(@"U.S. Department of Transportation's Aviation Consumer Protected Division Resource Page\n"
                                              @"http://airconsumer.ost.dot.gov/DiscrimComplaintsContacts.htm "
                                              @"Provides information about how and where to file complaints "
                                              @"about discriminatory treatment by air carrier personnel, federal "
                                              @"security screeners (e.g., personnel screening and searching "
                                              @"passengers and carry-on baggage at airport security checkpoints), "
                                              @"airport personnel (e.g., airport police), FBI, "
                                              @"Immigration and Customs Enforcement (ICE), U.S. Border "
                                              @"Patrol, Customs and Border Protection, and National Guard.", nil), nil],
                           [NSArray array], nil] retain];

        sectionLinks = [[NSArray arrayWithObjects:
                         [NSArray array],
                         [NSArray array],
                         [NSArray array],
                         [NSArray array],
                         [NSArray arrayWithObjects:
                          @"http://www.dhs.gov/xabout/structure/editorial_0373.shtm",
                          @"civil.liberties@dhs.gov",
                          @"http://airconsumer.ost.dot.gov/problems.htm",
                          @"airconsumer@ost.dot.gov",
                          @"http://airconsumer.ost.dot.gov/DiscrimComplaintsContacts.htm", nil],
                         [NSArray array], nil] retain];
        
        NSArray* questioningQuestions = 
        [NSArray arrayWithObjects:
         NSLocalizedString(@"What kind of law enforcement officers might try to question me?", nil),
         NSLocalizedString(@"Do I have to answer questions asked by law  enforcement officers?", nil),
         NSLocalizedString(@"Are there any exceptions to the general rule that I do not have to answer questions?", nil),
         NSLocalizedString(@"Can I talk to a lawyer before answering questions?", nil),
         NSLocalizedString(@"What if I speak to law enforcement officers anyway?", nil),
         NSLocalizedString(@"What if law enforcement officers threaten me with a grand "
                           @"jury subpoena if I don’t answer their questions?  (A grand jury "
                           @"subpoena is a written order for youabout information you may have.)", nil),
         NSLocalizedString(@"What if I am asked to meet with officers for a "
                           @"“counter-terrorism interview”?", nil), nil];
        
        NSArray* questioningAnswers = 
        [NSArray arrayWithObjects:
         NSLocalizedString(@"You could be questioned by a variety of law enforcement "
                           @"officers, including state or local police officers, Joint Terrorism "
                           @"Task Force members, or federal agents from the FBI, "
                           @"Department of Homeland Security (which includes "
                           @"Immigration and Customs Enforcement and the Border "
                           @"Patrol), Drug Enforcement Administration, Naval Criminal "
                           @"Investigative Service, or other agencies.", nil),
         NSLocalizedString(@"No. You have the constitutional right to remain silent. In "
                           @"general, you do not have to talk to law enforcement officers (or "
                           @"anyone else), even if you do not feel free to walk away from the "
                           @"officer, you are arrested, or you are in jail. You cannot be punished " 
                           @"for refusing to answer a question. It is a good idea to "
                           @"talk to a lawyer before agreeing to answer questions. In general, "
                           @"only a judge can order you to answer questions. "
                           @"(Non-citizens should see Section 4 for more information on "
                           @"this topic.)", nil),
         NSLocalizedString(@"Yes, there are two limited exceptions. First, in some states, "
                           @"you must provide your name to law enforcement officers if you "
                           @"are stopped and told to identify yourself. But even if you give "
                           @"your name, you are not required to answer other questions. "
                           @"Second, if you are driving and you are pulled over for a traffic "
                           @"violation, the officer can require you to show your license, "
                           @"vehicle registration and proof of insurance (but you do not "
                           @"have to answer questions). (Non-citizens should see Section 4 "
                           @"for more information on this topic.)", nil),
         NSLocalizedString(@"Yes. You have the constitutional right to talk to a lawyer "
                           @"before answering questions, whether or not the police tell you "
                           @"about that right. The lawyer’s job is to protect your rights. "
                           @"Once you say that you want to talk to a lawyer, officers should "
                           @"stop asking you questions. If they continue to ask questions, "
                           @"you still have the right to remain silent. If you do not have a "
                           @"lawyer, you may still tell the officer you want to speak to one before "
                           @"answering questions. If you do have a lawyer, keep his or her business "
                           @"card with you. Show it to the officer, and ask to call your lawyer. "
                           @"Remember to get the name, agency and telephone number of any law "
                           @"enforcement officer who stops or visits you, and give that information to "
                           @"your lawyer.", nil),
         NSLocalizedString(@"Anything you say to a law enforcement officer can be used against you "
                           @"and others. Keep in mind that lying to a government official is a crime "
                           @"but remaining silent until you consult with a lawyer is not. Even if you "
                           @"have already answered some questions, you can refuse to answer other "
                           @"questions until you have a lawyer.", nil),
         NSLocalizedString(@"If a law enforcement officer threatens to get a subpoena, you still do "
                           @"not have to answer the officer’s questions right then and there, and anything " 
                           @"you do say can be used against you. The officer may or may not "
                           @"succeed in getting the subpoena. If you receive a subpoena or an officer "
                           @"threatens to get one for you, you should call a lawyer right away. If you "
                           @"are given a subpoena, you must follow the subpoena’s direction about "
                           @"when and where to report to the court, but you can still assert your right "
                           @"not to say anything that could be used against you in a criminal case.", nil),
         NSLocalizedString(@"You have the right to say that you do not want to be interviewed, to "
                           @"have an attorney present, to set the time and place for the interview, to "
                           @"find out the questions they will ask beforehand, and to answer only the "
                           @"questions you feel comfortable answering. If you are taken into custody "
                           @"for any reason, you have the right to remain silent. No matter what, "
                           @"assume that nothing you say is off the record. And remember that it is a "
                           @"criminal offense to knowingly lie to an officer.", nil), nil];
        
        NSArray* stopsAndArrestsQuestions = 
        [NSArray arrayWithObjects:
         NSLocalizedString(@"What if law enforcement officers stop me on the street?", nil), 
         NSLocalizedString(@"What if law enforcement officers stop me in my car?", nil), 
         NSLocalizedString(@"What should I do if law enforcement officers arrest me?", nil), 
         NSLocalizedString(@"Do I have to answer questions if I have been arrested?", nil), 
         NSLocalizedString(@"What if I am treated badly by law enforcement officers?", nil), nil];
        
        NSArray* stopsAndArrestsAnswers = 
        [NSArray arrayWithObjects:
         NSLocalizedString(@"You do not have to answer any questions. You can say, “I do "
                           @"not want to talk to you” and walk away calmly. Or, if you do not "
                           @"feel comfortable doing that, you can ask if you are free to go. If "
                           @"the answer is yes, you can consider just walking away. Do not "
                           @"run from the officer. If the officer says you are not under "
                           @"arrest, but you are not free to go, then you are being detained. "
                           @"Being detained is not the same as being arrested, though an "
                           @"arrest could follow. The police can pat down the outside of "
                           @"your clothing only if they have “reasonable suspicion” (i.e., an "
                           @"objective reason to suspect) that you might be armed and dangerous. " 
                           @"If they search any more than this, say clearly, “I do not "
                           @"consent to a search.” If they keep searching anyway, do not "
                           @"physically resist them. You do not need to answer any questions "
                           @"if you are detained or arrested, except that the police may ask "
                           @"for your name once you have been detained, and you can be "
                           @"arrested in some states for refusing to provide it. (Non-citizens "
                           @"should see Section 4 for more information on this topic.)", nil),
         NSLocalizedString(@"Keep your hands where the police can see them. You must "
                           @"show your drivers license, registration and proof of insurance "
                           @"if you are asked for these documents. Officers can also ask "
                           @"you to step outside of the car, and they may separate passengers " 
                           @"and drivers from each other to question them and "
                           @"compare their answers, but no one has to answer any questions. " 
                           @"The police cannot search your car unless you give them "
                           @"your consent, which you do not have to give, or unless they "
                           @"have “probable cause” to believe (i.e., knowledge of facts sufficient "
                           @"to support a reasonable belief) that criminal activity is "
                           @"likely taking place, that you have been involved in a crime, or "
                           @"that you have evidence of a crime in your car. If you do not "
                           @"want your car searched, clearly state that you do not consent. "
                           @"The officer cannot use your refusal to give consent as a basis "
                           @"for doing a search.", nil), 
         NSLocalizedString(@"The officer must advise you of your constitutional rights to "
                           @"remain silent, to an attorney, and to have an attorney appointed "
                           @"if you cannot afford one. You should exercise all these "
                           @"rights, even if the officers don’t tell you about them. Do not tell "
                           @"the police anything except your name. Anything else you say can and will "
                           @"be used against you. Ask to see a lawyer immediately. Within a reasonable "
                           @"amount of time after your arrest or booking you have the right to a "
                           @"phone call. Law enforcement officers may not listen to a call you make "
                           @"to your lawyer, but they can listen to calls you make to other people. You "
                           @"must be taken before a judge as soon as possible-generally within 48 "
                           @"hours of your arrest at the latest.  (See Section 4 for information about "
                           @"arrests for noncriminal immigration violations.)", nil), 
         NSLocalizedString(@"No. If you are arrested, you do not have to answer any questions or "
                           @"volunteer any information. Ask for a lawyer right away. Repeat this "
                           @"request to every officer who tries to talk to or question you. You should "
                           @"always talk to a lawyer before you decide to answer any questions.", nil), 
         NSLocalizedString(@"Write down the officer’s badge number, name or other identifying "
                           @"information. You have a right to ask the officer for this information. Try to "
                           @"find witnesses and their names and phone numbers. If you are injured, "
                           @"seek medical attention and take pictures of the injuries as soon as you "
                           @"can. Call a lawyer or contact your local ACLU office. You should also "
                           @"make a complaint to the law enforcement office responsible for the "
                           @"treatment.", nil), nil];
        
        
        NSArray* searchesAndWarrantsQuestions = 
        [NSArray arrayWithObjects:
         NSLocalizedString(@"Can law enforcement officers search my home or office?", nil),
         NSLocalizedString(@"What are warrants and what should I make sure they say?", nil), 
         NSLocalizedString(@"What should I do if officers come to my house?", nil), 
         NSLocalizedString(@"Do I have to answer questions if law enforcement officers have a search or arrest warrant?", nil), 
         NSLocalizedString(@"What if law enforcement officers do not have a search warrant?", nil), 
         NSLocalizedString(@"What if law enforcement officers tell me they will come back "
                           @"with a search warrant if I do not let them in?", nil), 
         NSLocalizedString(@"What if law enforcement officers do not have a search "
                           @"warrant, but they insist on searching my home even "
                           @"after I object?", nil), nil];
        
        NSArray* searchesAndWarrantsAnswers = 
        [NSArray arrayWithObjects:
         NSLocalizedString(@"Law enforcement officers can search your home only if they "
                           @"have a warrant or your consent. In your absence, the police can "
                           @"search your home based on the consent of your roommate or a "
                           @"guest if the police reasonably believe that person has the "
                           @"authority to consent. Law enforcement officers can search your "
                           @"office only if they have a warrant or the consent of the employer. " 
                           @"If your employer consents to a search of your office, law "
                           @"enforcement officers can search your workspace whether you "
                           @"consent or not.", nil),
         NSLocalizedString(@"A warrant is a piece of paper signed by a judge giving law "
                           @"enforcement officers permission to enter a home or other "
                           @"building to do a search or make an arrest. A search warrant "
                           @"allows law enforcement officers to enter the place described in "
                           @"the warrant to look for and take items identified in the warrant. "
                           @"An arrest warrant allows law enforcement officers to take you "
                           @"into custody. An arrest warrant alone does not give law "
                           @"enforcement officers the right to search your home (but they "
                           @"can look in places where you might be hiding and they can take "
                           @"evidence that is in plain sight), and a search warrant alone "
                           @"does not give them the right to arrest you (but they can arrest "
                           @"you if they find enough evidence to justify an arrest). A warrant "
                           @"must contain the judge’s name, your name and address, the "
                           @"date, place to be searched, a description of any items being "
                           @"searched for, and the name of the agency that is conducting "
                           @"the search or arrest. An arrest warrant that does not have your "
                           @"name on it may still be validly used for your arrest if it "
                           @"describes you with enough detail to identify you, and a search "
                           @"warrant that does not have your name on it may still be valid if "
                           @"it gives the correct address and description of the place the "
                           @"officers will be searching. However, the fact that a piece of "
                           @"paper says “warrant” on it does not always mean that it is an "
                           @"arrest or search warrant. A warrant of deportation/removal, "
                           @"for example, is a kind of administrativewarrant and doesnot "
                           @"grant the same authority to enter a home or other building to "
                           @"do a search or make an arrest.", nil), 
         NSLocalizedString(@"If law enforcement officers knock on your door, instead of opening "
                           @"the door, ask through the door if they have a warrant. If the answer is "
                           @"no, do not let them into your home and do not answer any questions or "
                           @"say anything other than “I do not want to talk to you.” If the officers say "
                           @"that they do have a warrant, ask the officers to slip it under the door (or "
                           @"show it to you through a peephole, a window in your door, or a door that "
                           @"is open only enough to see the warrant). If you feel you must open the "
                           @"door, then step outside, close the door behind you and ask to see the "
                           @"warrant. Make sure the search warrant contains everything noted above, "
                           @"and tell the officers if they are at the wrong address or if you see some "
                           @"other mistake in the warrant. (And remember that an immigration “warrant "
                           @"of removal/deportation” does not give the officer the authority to "
                           @"enter your home.)  If you tell the officers that the warrant is not complete "
                           @"or not accurate, you should say you do not consent to the search, "
                           @"but you should not interfere if the officers decide to do the search even "
                           @"after you have told them they are mistaken. Call your lawyer as soon as "
                           @"possible. Ask if you are allowed to watch the search; if you are allowed "
                           @"to, you should. Take notes, including names, badge numbers, which "
                           @"agency each officer is from, where they searched and what they took. If "
                           @"others are present, have them act as witnesses to watch carefully what "
                           @"is happening.", nil), 
         NSLocalizedString(@"No. Neither a search nor arrest warrant means you have to answer "
                           @"questions.", nil), 
         NSLocalizedString(@"You do not have to let law enforcement officers search your home, "
                           @"and you do not have to answer their questions. Law enforcement officers "
                           @"cannot get a warrant based on your refusal, nor can they punish you for "
                           @"refusing to give consent.", nil), 
         NSLocalizedString(@"You can still tell them that you do not consent to the search and that "
                           @"they need to get a warrant. The officers may or may not succeed in getting " 
                           @"a warrant if they follow through and ask the court for one, but once "
                           @"you give your consent, they do not need to try to get the court’s permission " 
                           @"to do the search.", nil),
         NSLocalizedString(@"You should not interfere with the search in any way because "
                           @"you could get arrested. But you should say clearly that you "
                           @"have not given your consent and that the search is against your "
                           @"wishes. If someone is there with you, ask him or her to witness "
                           @"that you are not giving permission for the search. Call your "
                           @"lawyer as soon as possible. Take note of the names and badge "
                           @"numbers of the searching officers", nil), nil];
        
        
        NSArray* nonCitizensQuestions = 
        [NSArray arrayWithObjects:
         NSLocalizedString(@"What types of law enforcement officers may try to question me?", nil), 
         NSLocalizedString(@"What can I do if law enforcement officers want to question me?", nil), 
         NSLocalizedString(@"Do I have to answer questions about whether I am a U.S. citizen, " 
                           @"where I was born, where I live, where I am from, or other "
                           @"questions about my immigration status?", nil), 
         NSLocalizedString(@"Do I have to show officers my immigration documents?", nil), 
         NSLocalizedString(@"What should I do if there is an immigration raid where I work?", nil), 
         NSLocalizedString(@"What can I do if immigration officers are arresting me and I "
                           @"have children in my care or my children need to be picked up "
                           @"and taken care of?", nil), 
         NSLocalizedString(@"What should I do if immigration officers arrest me?", nil), 
         NSLocalizedString(@"Do I have the right to talk to a lawyer before answering any "
                           @"law enforcement officers’ questions or signing any immigration "
                           @"papers?", nil), 
         NSLocalizedString(@"If I am arrested for immigration violations, do I have "
                           @"the right to a hearing before an immigration judge to "
                           @"defend myself against deportation charges?", nil), 
         NSLocalizedString(@"Can I be detained while my immigration case is happening?", nil), 
         NSLocalizedString(@"Can I call my consulate if I am arrested?", nil), 
         NSLocalizedString(@"What happens if I give up my right to a hearing or "
                           @"leave the U.S. before the hearing is over?", nil), 
         NSLocalizedString(@"What should I do if I want to contact immigration officials?", nil), 
         NSLocalizedString(@"What if I am charged with a crime?", nil), nil];
        
        NSArray* nonCitizensAnswers = 
        [NSArray arrayWithObjects:
         NSLocalizedString(@"Different kinds of law enforcement officers might question you or ask "
                           @"you to agree to an interview where they would ask questions about your "
                           @"background, immigration status, relatives, colleagues and other topics. "
                           @"You may encounter the full range of law enforcement officers listed in "
                           @"Section 1.", nil),
         NSLocalizedString(@"You have the same right to be silent that U.S. citizens have, so the "
                           @"general rule is that you do not have to answer any questions that a law "
                           @"enforcement officer asks you. However, there are exceptions to this at "
                           @"ports of entry, such as airports and borders (see Section 5).", nil), 
         NSLocalizedString(@"You do not have to answer any of the above questions if you do not "
                           @"want to answer them. But do not falsely claim U.S. citizenship. It is "
                           @"almost always a good idea to speak with a lawyer before you answer "
                           @"questions about your immigration status. Immigration law is very "
                           @"complicated, and you could have a problem without realizing it. A lawyer can "
                           @"help protect your rights, advise you, and help you avoid a problem. "
                           @"Always remember that even if you have answered some questions, you "
                           @"can still decide you do not want to answer any more questions. "
                           @"For “nonimmigrants” (a “nonimmigrant” is a non-citizen who is "
                           @"authorized to be in the U.S. for a particular reason or activity, usually for "
                           @"a limited period of time, such as a person with a tourist, student, or "
                           @"work visa), there is one limited exception to the rule that non-citizens "
                           @"who are already in the U.S. do not have to answer law enforcement " 
                           @"officers’ questions: immigration officers can require "
                           @"nonimmigrants to provide information related to their immigration " 
                           @"status. However, even if you are a nonimmigrant, you can still "
                           @"say that you would like to have your lawyer with you before you "
                           @"answer questions, and you have the right to stay silent if your "
                           @"answer to a question could be used against you in a criminal case.", nil), 
         NSLocalizedString(@"The law requires non-citizens who are 18 or older and who "
                           @"have been issued valid U.S. immigration documents to carry "
                           @"those documents with them at all times. (These immigration "
                           @"documents are often called “alien registration” documents. "
                           @"The type you need to carry depends on your immigration status. "
                           @"Some examples include an unexpired permanent resident "
                           @"card (“green card”), I-94, Employment Authorization Document "
                           @"(EAD), or border crossing card.)  Failure to comply carry these "
                           @"documents can be a misdemeanor crime. "
                           @"If you have your valid U.S. immigration documents and "
                           @"you are asked for them, then it is usually a good idea to show "
                           @"them to the officer because it is possible that you will be "
                           @"arrested if you do not do so. Keep a copy of your documents in "
                           @"a safe place and apply for a replacement immediately if you "
                           @"lose your documents or if they are going to expire. If you are "
                           @"arrested because you do not have your U.S. immigration documents "
                           @"with you, but you have them elsewhere, ask a friend or "
                           @"family member (preferably one who has valid immigration status) "
                           @"to bring them to you. "
                           @"It is never a good idea to show an officer fake immigration "
                           @"documents or to pretend that someone else’s immigration "
                           @"documents are yours. If you are undocumented and therefore "
                           @"do not have valid U.S. immigration documents, you can decide "
                           @"not to answer questions about your citizenship or immigration "
                           @"status or whether you have documents. If you tell an immigration "
                           @"officer that you are not a U.S. citizen and you then cannot "
                           @"produce valid U.S. immigration documents, there is a very good "
                           @"chance you will be arrested.", nil), 
         NSLocalizedString(@"If your workplace is raided, it may not be clear to you "
                           @"whether you are free to leave. Either way, you have the right to "
                           @"remain silent-you do not have to answer questions about your "
                           @"citizenship, immigration status or anything else. If you do "
                           @"answer questions and you say that you are not a U.S. citizen, you will be "
                           @"expected to produce immigration documents showing your immigration "
                           @"status. If you try to run away, the immigration officers will assume that "
                           @"you are in the U.S. illegally and you will likely be arrested. The safer "
                           @"course is to continue with your work or calmly ask if you may leave, and "
                           @"to not answer any questions you do not want to answer. (If you are a "
                           @"“nonimmigrant,” see above.)", nil), 
         NSLocalizedString(@"If you have children with you when you are arrested, ask the officers "
                           @"if you can call a family member or friend to come take care of them "
                           @"before the officers take you away. If you are arrested when your children "
                           @"are at school or elsewhere, call a friend or family member as soon as "
                           @"possible so that a responsible adult will be able to take care of them.", nil), 
         NSLocalizedString(@"Assert your rights.Non-citizens have rights that are important for "
                           @"their immigration cases. You do not have to answer questions. You can "
                           @"tell the officer you want to speak with a lawyer. You do not have to sign "
                           @"anything giving up your rights, and should never sign anything without "
                           @"reading, understanding and knowing the consequences of signing it. If "
                           @"you do sign a waiver, immigration agents could try to deport you before "
                           @"you see a lawyer or a judge. The immigration laws are hard to understand. "
                           @"There may be options for you that the immigration officers will "
                           @"not explain to you. You should talk to a lawyer before signing anything or "
                           @"making a decision about your situation. If possible, carry with you the "
                           @"name and telephone number of a lawyer who will take your calls.", nil), 
         NSLocalizedString(@"Yes. You have the right to call a lawyer or your family if you are "
                           @"detained, and you have the right to be visited by a lawyer in detention. "
                           @"You have the right to have your attorney with you at any hearing before "
                           @"an immigration judge. You do not have the right to a government-" 
                           @"appointed attorney for immigration proceedings, but immigration "
                           @"officials must give you a list of free or low-cost legal service providers. "
                           @"You have the right to hire your own immigration attorney.", nil), 
         NSLocalizedString(@"Yes. In most cases only an immigration judge can order you "
                           @"deported. But if you waive your rights, sign something called a "
                           @"“Stipulated Removal Order,” or take “voluntary departure,” "
                           @"agreeing to leave the country, you could be deported without a "
                           @"hearing. There are some reasons why a person might not have "
                           @"a right to see an immigration judge, but even if you are told "
                           @"that this is your situation, you should speak with a lawyer "
                           @"immediately-immigration officers do not always know or tell "
                           @"you about exceptions that may apply to you; and you could have "
                           @"a right that you do not know about. Also, it is very important "
                           @"that you tell the officer (and contact a lawyer) immediately if "
                           @"you fear persecution or torture in your home country-you have "
                           @"additional rights if you have this fear, and you may be able to "
                           @"win the right to stay here.", nil), 
         NSLocalizedString(@"In many cases, you will be detained, but most people are "
                           @"eligible to be released on bond or other reporting conditions. If "
                           @"you are denied release after you are arrested for an immigration "
                           @"violation, ask for a bond hearing before an immigration "
                           @"judge. In many cases, an immigration judge can order that you "
                           @"be releasedor that your bond be lowered.", nil), 
         NSLocalizedString(@"Yes. Non-citizens arrested in the U.S. have the right to call "
                           @"their consulate or to have the law enforcement officer tell the "
                           @"consulate of your arrest. Law enforcement must let your consulate "
                           @"visit or speak with you if consular officials decide to do so. "
                           @"Your consulate might help you find a lawyer or offer other help.", nil), 
         NSLocalizedString(@"If you are deported, you could lose your eligibility for certain "
                           @"immigration benefits, and you could be barred from returning "
                           @"to the U.S. for a number of years or, in some cases, permanently. "
                           @"The same is true if you do not go to your hearing and "
                           @"the immigration judge rules against you in your absence. If the "
                           @"government allows you to do “voluntary departure,” you may "
                           @"avoid some of the problems that come with having a deportation "
                           @"order and you may have a better chance at having a future opportunity "
                           @"to return to the U.S., but you should discuss your case with a lawyer "
                           @"because even with voluntary departure, there can be bars to returning, "
                           @"and you may be eligible for relief in immigration court. You should "
                           @"always talk to an immigration lawyer before you decide to give up your "
                           @"right to a hearing.", nil), 
         NSLocalizedString(@"Always try to talk to a lawyer before contacting immigration officials, "
                           @"even on the phone. Many immigration officials view “enforcement” as "
                           @"their primary job and will not explain all of your options to you, and you "
                           @"could have a problem with your immigration status without knowing it.", nil), 
         NSLocalizedString(@"Criminal convictions can make you deportable. You should always "
                           @"speak with your lawyer about the effect that a conviction or plea could "
                           @"have on your immigration status. Do not agree to a plea bargain without "
                           @"understanding if it could make you deportable or ineligible for relief or "
                           @"for citizenship.", nil), nil];
        
        NSArray* portsOfEntryQuestions = 
        [NSArray arrayWithObjects:
         NSLocalizedString(@"What types of officers could I encounter at the airport and at the border?", nil),
         NSLocalizedString(@"If I am entering the U.S. with valid travel papers, can "
                           @"law enforcement officers stop and search me?", nil),
         NSLocalizedString(@"Can law enforcement officers ask questions about my "
                           @"immigration status?", nil),
         NSLocalizedString(@"If I am selected for a longer interview when I am "
                           @"coming into the United States, what can I do?", nil),
         NSLocalizedString(@"Can law enforcement officers search my laptop files?  If they "
                           @"do, can they make copies of the files, or information from my "
                           @"address book, papers, or cell phone contacts?", nil),
         NSLocalizedString(@"Can my bags or I be searched after going through metal "
                           @"detectors with no problem or after security sees that my bags do "
                           @"not contain a weapon?", nil),
         NSLocalizedString(@"What if I wear a religious head covering and I am selected by "
                           @"airport security officials for additional screening?", nil),
         NSLocalizedString(@"What if I am selected for a strip search?", nil),
         NSLocalizedString(@"If I am on an airplane, can an airline employee interrogate me or ask me to get off the plane?", nil),
         NSLocalizedString(@"What do I do if I am questioned by law enforcement "
                           @"officers every time I travel by air and I believe I am on a "
                           @"“no-fly” or other “national security” list?", nil),
         NSLocalizedString(@"If I believe that customs or airport agents or airline "
                           @"employees singled me out because of my race, ethnicity, "
                           @"or religion or that I was mistreated in other ways, what "
                           @"information should I record during and after the incident?", nil), nil];
        
        NSArray* portsOfEntryAnswers = 
        [NSArray arrayWithObjects:
         NSLocalizedString(@"You may encounter any of the full range of law enforcement "
                           @"officers listed above in Section 1. In particular, at airports and "
                           @"at the border you are likely to encounter customs agents, "
                           @"immigration officers, and Transportation and Safety "
                           @"Administration (TSA) officers.", nil),
         NSLocalizedString(@"Yes. Customs officers have the right to stop, detain and "
                           @"search any person or item. But officers cannot select you for a "
                           @"personal search based on your race, gender, religious or ethnic "
                           @"background. If you are a non-citizen, you should carry your "
                           @"green card or other valid immigration status documents at all "
                           @"times.", nil),
         NSLocalizedString(@"Yes. At airports, law enforcement officers have the power to "
                           @"determine whether or not you have the right or permission to "
                           @"enter or return to the U.S.", nil),
         NSLocalizedString(@"If you are a U.S. citizen, you have the right to have an attorney " 
                           @"present for any questioning. If you are a non-citizen, you "
                           @"generally do not have the right to an attorney when you have "
                           @"arrived at an airport or another port of entry and an immigration "
                           @"officer is inspecting you to decide whether or not you will "
                           @"be admitted. However, you do have the right to an attorney if "
                           @"the questions relate to anything other than your immigration "
                           @"status. You can ask an officer if he or she will allow you to "
                           @"answer extended questioning at a later time, but the request may or may "
                           @"not be granted. If you are not a U.S. citizen and an officer says you " 
                           @"cannot come into the U.S., but you fear that you will be persecuted or "
                           @"tortured if sent back to the country you came from, tell the officer about "
                           @"your fear and say that you want asylum.", nil),
         NSLocalizedString(@"This issue is contested right now. Generally, law enforcement officers "
                           @"can search your laptop files and make copies of information contained in "
                           @"the files. If such a search occurs, you should write down the name, "
                           @"badge number, and agency of the person who conducted the search. You "
                           @"should also file a complaint with that agency.", nil),
         NSLocalizedString(@"Yes. Even if the initial screen of your bags reveals nothing suspicious, "
                           @"the screeners have the authority to conduct a further search of you or "
                           @"your bags.", nil),
         NSLocalizedString(@"You have the right to wear religious head coverings. You should assert "
                           @"your right to wear your religious head covering if asked to remove it. The "
                           @"current policy (which is subject to change) relating to airport screeners "
                           @"and requiring removal of religious head coverings, such as a turban or "
                           @"hijab, is that if an alarm goes off when you walk through the metal "
                           @"detector the TSA officer may then use a hand-wand to determine if the "
                           @"alarm is coming from your religious head covering. If the alarm is coming " 
                           @"from your religious head covering the TSA officer may want to "
                           @"pat-down or have you remove your religious head covering. You have the "
                           @"right to request that this pat-down or removal occur in a private area. If "
                           @"no alarm goes off when you go through the metal detector the TSA officer "
                           @"may nonetheless determine that additional screening is required for "
                           @"non-metallic items. Additional screening cannot be required on a " 
                           @"discriminatory basis (because of race, gender, religion, national origin or "
                           @"ancestry). The TSA officer will ask you if he or she can pat-down your "
                           @"religious head covering. If you do not want the TSA officer to touch your "
                           @"religious head covering you must refuse and say that you would prefer to "
                           @"pat-down your own religious head covering. You will then be taken aside "
                           @"and a TSA officer will supervise you as you pat-down your religious head "
                           @"covering. After the pat-down the TSA officer will rub your "
                           @"hands with a small cotton cloth and place it in a machine to "
                           @"test for chemical residue. If you pass this chemical residue "
                           @"test, you should be allowed to proceed to your flight. If the TSA "
                           @"officer insists on the removal of your religious head covering "
                           @"you have a right to ask that it be done in a private area.", nil),
         NSLocalizedString(@"A strip search at the border is not a routine search and "
                           @"must be supported by “reasonable suspicion,” and must be "
                           @"done in a private area.", nil),
         NSLocalizedString(@"The pilot of an airplane has the right to refuse to fly a " 
                           @"passenger if he or she believes the passenger is a threat to the "
                           @"safety of the flight. The pilot’s decision must be reasonable and "
                           @"based on observations of you, not stereotypes.", nil),
         NSLocalizedString(@"If you believe you are mistakenly on a list you should contact "
                           @"the Transportation Security Administration and file an inquiry "
                           @"using the Traveler Redress Inquiry Process. The form is available at " 
                           @"http://www.tsa.gov/travelers/customer/redress/index.shtm. "
                           @"You should also fill out a complaint form with the ACLU at "
                           @"http://www.aclu.org/noflycomplaint. If you think there may be "
                           @"some legitimate reason for why you have been placed on a list, "
                           @"you should seek the advice of an attorney.", nil),
         NSLocalizedString(@"It is important to record the details of the incident while they "
                           @"are fresh in your mind. When documenting the sequence of "
                           @"events, be sure to note the airport, airline, flight number, the "
                           @"names and badge numbers of any law enforcement officers "
                           @"involved, information on any airline or airport personnel "
                           @"involved, questions asked in any interrogation, stated reason "
                           @"for treatment, types of searches conducted, and length and conditions of "
                           @"detention. When possible, it is helpful to have a witness to the incident. If "
                           @"you have been mistreated or singled out at the airport based on your "
                           @"race, ethnicity or religion, please fill out the Passenger Profiling "
                           @"Complaint Form on the ACLU’s web site at http://www.aclu.org/airlineprofiling, "
                           @"and file a complaint with the U.S. Department of "
                           @"Transportation at "
                           @"http://airconsumer.ost.dot.gov/DiscrimComplaintsContacts.htm.", nil), nil];
        
        NSArray* portsOfEntryLinks = 
        [NSArray arrayWithObjects:
         [NSArray array],
         [NSArray array],
         [NSArray array],
         [NSArray array],
         [NSArray array],
         [NSArray array],
         [NSArray array],
         [NSArray array],
         [NSArray array],
         [NSArray arrayWithObjects:@"http://www.tsa.gov/travelers/customer/redress/index.shtm", @"http://www.aclu.org/noflycomplaint", nil],
         [NSArray arrayWithObjects:@"http://www.aclu.org/airlineprofiling", @"http://airconsumer.ost.dot.gov/DiscrimComplaintsContacts.htm", nil],
         nil];
        
        NSArray* charitableDonationsQuestions = 
        [NSArray arrayWithObjects:
         NSLocalizedString(@"Can I give to a charity organization without becoming a "
                           @"terror suspect?", nil), 
         NSLocalizedString(@"Is it safe for me to practice my religion in religious "
                           @"institutions or public places?", nil), 
         NSLocalizedString(@"What else can I do to be prepared?", nil), nil];
        
        NSArray* charitableDonationsAnswers = 
        [NSArray arrayWithObjects:
         NSLocalizedString(@"Yes. You should continue to give money to the causes you believe "
                           @"in, but you should be careful in choosing which charities to support." 
                           @"For helpful tips, see Muslim Advocates’ guide on charitable giving: "
                           @"http://www.muslimadvocates.org/documents/safe_donating.html.", nil), 
         NSLocalizedString(@"Yes. Worshipping as you want is your constitutional right. You "
                           @"have the right to go to a place of worship, attend and hear sermons "
                           @"and religious lectures, participate in community activities, and pray "
                           @"in public. While there have been news stories recently about people "
                           @"being unfairly singled out for doing these things, the law is on your "
                           @"side to protect you.", nil), 
         NSLocalizedString(@"You should keep informed about issues that matter to you by "
                           @"going to the library, reading the news, surfing the internet, and "
                           @"speaking out about what is important to you. In case of emergency, "
                           @"you should have a family plan-the number of a good friend or "
                           @"relative that anyone in the family can call if they need help, as well "
                           @"as the number of an attorney. If you are a non-citizen, remember to "
                           @"carry your immigration documents with you.", nil), nil];
        
        NSArray* charitableDonationsLinks = 
        [NSArray arrayWithObjects:
         [NSArray arrayWithObjects:@"http://www.muslimadvocates.org/documents/safe_donating.html", nil],
         [NSArray array],
         [NSArray array], nil];
        
        questions = [[NSArray arrayWithObjects:
                      questioningQuestions, 
                      stopsAndArrestsQuestions,
                      searchesAndWarrantsQuestions,
                      nonCitizensQuestions,
                      portsOfEntryQuestions,
                      charitableDonationsQuestions, nil] retain];
        answers = [[NSArray arrayWithObjects:
                    questioningAnswers,
                    stopsAndArrestsAnswers,
                    searchesAndWarrantsAnswers,
                    nonCitizensAnswers,
                    portsOfEntryAnswers,
                    charitableDonationsAnswers, nil] retain];
        
        links = [[NSArray arrayWithObjects:
                 [NSArray array],
                 [NSArray array],
                 [NSArray array],
                 [NSArray array],
                 portsOfEntryLinks,
                  charitableDonationsLinks, nil] retain];
    }
}


+ (NSArray*) sectionTitles {
    return sectionTitles;
}


+ (NSArray*) shortSectionTitles {
    return shortSectionTitles;
}


+ (NSString*) shortSectionTitleForSectionTitle:(NSString*) sectionTitle {
    return [shortSectionTitles objectAtIndex:[sectionTitles indexOfObject:sectionTitle]];
}


+ (NSString*) preambleForSectionTitle:(NSString*) sectionTitle {
    return [preambles objectAtIndex:[sectionTitles indexOfObject:sectionTitle]];
}


+ (NSArray*) questionsForSectionTitle:(NSString*) sectionTitle {
    return [questions objectAtIndex:[sectionTitles indexOfObject:sectionTitle]];
}


+ (NSArray*) otherResourcesForSectionTitle:(NSString*) sectionTitle {
    return [otherResources objectAtIndex:[sectionTitles indexOfObject:sectionTitle]];
}


+ (NSArray*) answersForSectionTitle:(NSString*) sectionTitle {
    return [answers objectAtIndex:[sectionTitles indexOfObject:sectionTitle]];
}


+ (NSString*) answerForQuestion:(NSString*) question withSectionTitle:(NSString*) sectionTitle {
    NSArray* questions = [self questionsForSectionTitle:sectionTitle];
    NSArray* specificAnswers = [self answersForSectionTitle:sectionTitle];
    
    return [specificAnswers objectAtIndex:[questions indexOfObject:question]];
}


+ (NSArray*) linksForSectionTitle:(NSString*) sectionTitle {
    return [sectionLinks objectAtIndex:[sectionTitles indexOfObject:sectionTitle]];
}


+ (NSArray*) linksForQuestion:(NSString*) question withSectionTitle:(NSString*) sectionTitle {
    NSArray* questions = [self questionsForSectionTitle:sectionTitle];
    NSArray* specificLinks = [links objectAtIndex:[sectionTitles indexOfObject:sectionTitle]];
    return [specificLinks objectAtIndex:[questions indexOfObject:question]];
}


@end
