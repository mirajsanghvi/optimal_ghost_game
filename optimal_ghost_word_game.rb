#Miraj Sanghvi
#mirajsanghvi@gmail.com
#Optimal Ghost word game 
#enter "make db" to make db, or "start" to begin game.
#enjoy!


require "rubygems"
require "sqlite3"

def make_db()
	
  	db = SQLite3::Database.new( "words.db" )
  	
	db.execute("CREATE TABLE word_game (
		word TEXT
		);")
	
	input_file="word.lst"
	
	current_file = File.open(input_file)
	line=current_file.readline()
	current_file.seek(0, IO::SEEK_SET)
	for line in current_file   	
		db.execute( "INSERT INTO word_game (word) VALUES (?);", "#{line}")
	end
	
	db.execute( "CREATE UNIQUE INDEX p_word_game ON word_game (word);")
end

def start_game()
	puts "This is a game...please enter a letter to start."
	word=''
	word_found=0
	
	db = SQLite3::Database.open( "words.db" )
	
	db_check_word=db.execute( "SELECT * FROM word_game WHERE word LIKE ?","#{word}%")
	
	while word_found==0
		word.downcase!
		
		print "enter next letter > "; 
		word<<gets.chomp()[0..0]
		print "word at: ", word
		puts ""
		
		db_check_word=db.execute( "SELECT * FROM word_game WHERE word LIKE ?","#{word}%")
		db_check_word.each do |row|
			word_1=row.to_s.slice!(2..-1).chomp!('\n"]')
						
			if "#{word_1}"=="#{word}" and "#{word}".length>4
				puts "\n GAME OVER"
				puts "you lose"
				word_found=1
				Process.exit(1)
			end
		end
		
		if db_check_word[0].nil?
			puts "\n GAME OVER"
			puts "no words like that - you lose"
			word_found=1
			Process.exit(1)
		end
		
		high_l=0
		win_length=100
		next_letter=''
		end_next_letter=''
		win_next_letter=''
		letters = ('A'..'Z').to_a
		
		for l in letters 
			res = db.execute("SELECT COUNT(word) FROM word_game WHERE word LIKE '#{word}#{l}%';")
			_curr_cnt=res[0].to_s
			_curr_cnt=_curr_cnt.scan(/\d/).join().to_i
			not_this_letter=0
			
			if _curr_cnt>high_l
				new_pl_word=db.execute( "SELECT word FROM word_game WHERE word LIKE '#{word}#{l}%';")
				
				new_pl_word.each do |row|
					word_1=row.to_s.slice!(2..-1).chomp!('\n"]')
					
					if "#{word_1}"=="#{word}#{l}".downcase! and "#{word_1}".length>4
						not_this_letter=1
						end_next_letter=l
  					elsif not_this_letter!=1
  						high_l=_curr_cnt
						next_letter=l
  					end
  				end
			end
			
			if "#{word}#{l}_".length>4
				res_win = db.execute("SELECT COUNT(word) FROM word_game WHERE word LIKE '#{word}#{l}__%';")
				_curr_cnt_win=res_win[0].to_s
				_curr_cnt_win=_curr_cnt_win.scan(/\d/).join().to_i
				if _curr_cnt_win==1
					new_pl_word_win=db.execute( "SELECT word FROM word_game WHERE word LIKE '#{word}#{l}__%';")
					new_pl_word_win.each do |row|
						word_1=row.to_s.slice!(2..-1).chomp!('\n"]')
						if ("#{word_1}".length) %2 >0 and "#{word_1}".length>4
							if "#{word_1}".length<win_length
								win_next_letter=l
								win_length="#{word_1}".length
							end
						end
					end
				end
			end
		end
		
		if next_letter=='' 
			next_letter=end_next_letter
		end
		if win_next_letter!=''
			next_letter=win_next_letter
		end
		
		word << next_letter		
		word.downcase!
		print "computer plays..." 
		puts word
		db_check_word=db.execute( "SELECT * FROM word_game WHERE word LIKE ?","#{word}%")
		
		db_check_word.each do |row|
			word_1=row.to_s.slice!(2..-1).chomp!('\n"]')
			if "#{word_1}"=="#{word}" and "#{word}".length>4
				puts "\n GAME OVER"
				puts "computer loses"
				word_found=1
				Process.exit(1)
			end
		end
	end
end

def start()
	puts "make db or start?"
	print "> "
	action = gets.chomp()
	
	if action == "make db"
		make_db()
	elsif action == "start"
		start_game()
	end;
end;


start()
