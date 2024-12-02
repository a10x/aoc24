module aoc;

import std::io;
import std::collections::map;

const NUM_DIGITS = 5;
const NUM_NUMS = 1000;
const NUM_GAPS = 3;
const LINE_SIZE = (NUM_DIGITS * 2) + NUM_GAPS + 1;
const CHUNK_SIZE = 100 * LINE_SIZE;

def NumToCountMap = HashMap(<uint, ushort>);

fn void! main(){
	uint[] left = mem::new_array(uint, NUM_NUMS);
	uint[] right = mem::new_array(uint, NUM_NUMS);
	char[] buffer = mem::new_array(char, CHUNK_SIZE);
	defer free(left);
	defer free(right);
	defer free(buffer);
	
	File file = file::open("input.txt", "r")!;
	defer (void)file.close();

	uint arr_count = 0;
	while(arr_count < NUM_NUMS){
		file.read(buffer)!;
		char[] left_view, right_view;
		uint count = 0;
		while(count < CHUNK_SIZE && arr_count < NUM_NUMS){
			//23454...23454.52344...34345
			uint right_i = count+(NUM_DIGITS+NUM_GAPS);
			left_view = buffer[count..count+NUM_DIGITS-1];
			count += NUM_DIGITS + NUM_GAPS;
			right_view = buffer[count..count+NUM_DIGITS-1];
			left[arr_count] = to_int(left_view);
			right[arr_count] = to_int(right_view);
			count += NUM_DIGITS + 1;
			++arr_count;
		}
	}
	left = sort_arr(left);
	right = sort_arr(right);
	uint running_total = 0;
	//part 2
	NumToCountMap num_map;
	num_map.new_init();

	for(ushort i = 0; i < NUM_NUMS; ++i){
		int diff = left[i] - right[i];
		int mask = diff >> 31;
		running_total += ((diff + mask) ^ mask);

		//part 2
		ushort count = num_map.@get_or_set(right[i], 0);
		num_map.set(right[i], ++count);
	}
	io::printfn("total: %d", running_total);

	//part 2
	ulong sim_score = 0;
	for(ushort i = 0; i < NUM_NUMS; ++i){
		if(num_map.has_key(left[i])){
			sim_score += ( (ulong)num_map.get(left[i])! * left[i]);
		}
	}
	io::printfn("sim score: %d", sim_score);
}

fn uint[] sort_arr(uint[] nums){
	uint[] sorted = mem::new_array(uint, NUM_NUMS);
	defer free(sorted);

	uint factor = 1;
	ushort[10] freq;
	char iter = 0;
	while(iter < NUM_DIGITS){
		freq = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
		foreach(&num : nums){
			char digit = (char)((*num / factor) % 10);
			freq[digit] += 1;
		}
		for(char i = 1; i < 10; ++i){
			freq[i] += freq[i-1];
		}
		for(ushort i = 0; i < NUM_NUMS; ++i){
			uint num = nums[NUM_NUMS-1-i];
			char digit = (char)((num / factor) % 10);
			ushort index = freq[digit] - 1u8;
			freq[digit] = index;
			sorted[index] = num;
		}
		factor *= 10;
		++iter;
		uint[] temp = nums;
		nums = sorted;
		sorted = temp;
	}
	return nums;
}


fn uint to_int(char[] chars){
	uint num = 0;
	uint factor = 1;
	for(uint i = NUM_DIGITS; i > 0; --i){
		num = (chars[i - 1] - 48) * factor + num;
		factor *= 10;
	}
	return num;
}

