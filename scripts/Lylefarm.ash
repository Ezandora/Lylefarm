//Farms dust bunnies and stock certificates for Lyle, Traveling Infrastructure Specialist.
//This script is in the public domain.
//Written by Ezandora.

string __lyle_version = "1.0.1";

boolean run_choice_by_text(string page_text, string identifier)
{
	foreach s in $strings[?,(,)]
		identifier = identifier.replace_string(s, "\\" + s); //FIXME remove/escape other grepables
	string [int][int] matches = page_text.group_string("value=\"?([0-9]*)\"?><input [ ]*class=button type=submit value=\"" + identifier);
	int choice_id = matches[0][1].to_int();
	if (choice_id <= 0)
		return false;
	run_choice(choice_id);
	return true;
}


void reachFarmingPage()
{
	visit_url("place.php?whichplace=town_right&action=townright_lyle");
	int breakout = 20;
	while (breakout > 0)
	{
		breakout -= 1;
		buffer page_text = visit_url("choice.php");
		if (page_text.contains_text("All you need is ten thousand meat and a dream"))
		{
			//print_html("Reached farming page.");
			return;
		}
		
		if (run_choice_by_text(page_text, "Ok, ok, skip to the good part"))
			continue;
		if (run_choice_by_text(page_text, "What'll you call it when it's done?"))
			continue;
		if (run_choice_by_text(page_text, "That sounds good, I'll buy if I'm able!"))
			continue;
		if (run_choice_by_text(page_text, "That idea sure sounds whack!"))
			continue;
		if (run_choice_by_text(page_text, "That sounds neat, but where will it go?"))
			continue;
		if (run_choice_by_text(page_text, "Why wouldn't I just drive a car?"))
			continue;
		if (run_choice_by_text(page_text, "Now, this sounds great, what it called?"))
			continue;
		if (run_choice_by_text(page_text, "Stock you say, you're here to hock?"))
			continue;
		if (run_choice_by_text(page_text, "10,000 Meat?  Well that seems fair"))
			continue;
		abort("Unable to help, stopping.");
	}
}

void escapeLyle()
{
	int breakout = 5;
	while (breakout > 0)
	{
		breakout -= 1;
		buffer page_text = visit_url("choice.php");
		if (page_text.contains_text("If your pocketbook is low on bank"))
		{
			run_choice_by_text(page_text, "0 Meat");
		}
		else if (page_text.contains_text("Sorry, Bud, this plan"))
		{
			run_choice_by_text(page_text, "Sorry, Bud, this plan seems unstable.");
		}
		else if (page_text.contains_text("refurbishing this old building by the train yard"))
		{
			run_choice_by_text(page_text, "Uh, no thanks.");
		}
	}
}

void main(int adventures_to_use)
{
	print_html("Lylefarm version " + __lyle_version + ".");
	if (adventures_to_use < 5 || my_adventures() < 5)
	{
		print_html("<font color=\"red\">Need at least five adventures to farm this absolutely legitimate and worthwhile stock.</font>");
		return;
	}
	boolean [item] relevant_items;
	relevant_items[to_item("L.I.M.P. Stock Certificate")] = true;
	relevant_items[to_item("dust bunny")] = true;
	int [item] amount_before;
	foreach it in relevant_items
		amount_before[it] = it.item_amount();
	
	reachFarmingPage();
	int breakout = 300;
	while (my_adventures() >= 5 && adventures_to_use >= 5 && breakout > 0)
	{
		breakout -= 1;
		buffer page_text = visit_url("choice.php");
		if (!page_text.contains_text("How about sweat"))
		{
			break;
		}
		
		//print_html("page_text = " + page_text.entity_encode());
		run_choice_by_text(page_text, "How about sweat equity? (5 adventures)");
		
		adventures_to_use -= 5;
	}
	escapeLyle();
	print_html("");
	foreach it in relevant_items
	{
		int delta = it.item_amount() - amount_before[it];
		if (delta > 0)
		{
			print("Collected " + delta + " " + (delta > 1 ? it.plural : it) + ".");
		}
	}
	print_html("Done.");
}