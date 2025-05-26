using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ITapply.Models.Responses
{
    public class SkillResponse
    {
        public int Id { get; set; }

        public string Name { get; set; } = string.Empty;
    }
} 